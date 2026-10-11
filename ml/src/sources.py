"""Readers for each raw dataset source.

Every reader yields :class:`RawRecord` objects - one image plus its native
(non-normalised) label. Archives and embedded-image formats (parquet) are
unpacked on demand into ``data/extracted/`` so downstream stages only ever
deal with plain image files on disk.
"""
from __future__ import annotations

import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

import config

# File extensions treated as images anywhere in the pipeline.
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".gif", ".webp"}


@dataclass(frozen=True)
class RawRecord:
    """A single raw image and the label it carries in its source dataset."""

    path: Path
    source: str
    raw_label: str
    category: str = ""


# ---------------------------------------------------------------------------
# Safety helpers
# ---------------------------------------------------------------------------
def _safe_extract(member: str, dest: Path) -> bool:
    """Reject zip members that would escape ``dest`` (zip-slip protection)."""
    target = (dest / member).resolve()
    return str(target).startswith(str(dest.resolve()))


def extract_zip(zip_path: Path, dest: Path) -> Path:
    """Extract ``zip_path`` into ``dest`` once; return the extraction root."""
    dest.mkdir(parents=True, exist_ok=True)
    marker = dest / f".{zip_path.stem}.done"
    if marker.exists():
        return dest
    with zipfile.ZipFile(zip_path) as archive:
        for member in archive.namelist():
            if _safe_extract(member, dest):
                archive.extract(member, dest)
    marker.touch()
    return dest


# ---------------------------------------------------------------------------
# deepghs/nsfw_detect  (zip of class folders)
# ---------------------------------------------------------------------------
def iter_nsfw_detect() -> Iterator[RawRecord]:
    zip_path = config.RAW_DIR / "nsfw_detect" / "nsfw_dataset_v1.zip"
    if not zip_path.exists():
        return
    root = extract_zip(zip_path, config.EXTRACT_DIR / "nsfw_detect")
    dataset_root = root / "nsfw_dataset_v1"
    base = dataset_root if dataset_root.exists() else root
    for class_dir in sorted(p for p in base.iterdir() if p.is_dir()):
        raw_label = class_dir.name
        for img in sorted(class_dir.rglob("*")):
            if img.suffix.lower() in IMAGE_EXTENSIONS:
                yield RawRecord(img, "nsfw_detect", raw_label, category=raw_label)


# ---------------------------------------------------------------------------
# ChinaZhangPeng/Violence-Image-Dataset  (rgb frames, all violent)
# ---------------------------------------------------------------------------
def iter_violence_images() -> Iterator[RawRecord]:
    images = (
        config.RAW_DIR
        / "violence_images"
        / "Violence-Image-Dataset-master"
        / "rgb"
        / "images"
    )
    if not images.exists():
        return
    for img in sorted(images.rglob("*")):
        if img.suffix.lower() in IMAGE_EXTENSIONS:
            yield RawRecord(img, "violence_images", "violence", category="violence")


# ---------------------------------------------------------------------------
# yiting/UnsafeBench  (parquet with embedded image bytes)
# ---------------------------------------------------------------------------
def iter_unsafebench() -> Iterator[RawRecord]:
    """Extract embedded images from the UnsafeBench parquet shards.

    Requires ``pyarrow`` (imported lazily so the rest of the pipeline works
    without it).
    """
    parquet_dir = config.RAW_DIR / "UnsafeBench" / "data"
    if not parquet_dir.exists():
        return
    try:
        import pyarrow.parquet as pq
    except ImportError as exc:  # pragma: no cover - dependency guard
        raise RuntimeError(
            "pyarrow is required to read UnsafeBench parquet files"
        ) from exc

    out_root = config.EXTRACT_DIR / "UnsafeBench"
    out_root.mkdir(parents=True, exist_ok=True)

    for parquet_file in sorted(parquet_dir.glob("*.parquet")):
        split = parquet_file.stem.split("-")[0]
        split_dir = out_root / split
        split_dir.mkdir(parents=True, exist_ok=True)
        table = pq.read_table(parquet_file)
        rows = table.to_pylist()
        for index, row in enumerate(rows):
            image = row.get("image") or {}
            data = image.get("bytes")
            if not data:
                continue
            out_path = split_dir / f"{index:06d}.jpg"
            if not out_path.exists():
                out_path.write_bytes(data)
            yield RawRecord(
                out_path,
                "UnsafeBench",
                str(row.get("safety_label", "")),
                category=str(row.get("category", "")),
            )


# ---------------------------------------------------------------------------
# Registry
# ---------------------------------------------------------------------------
READERS = {
    "nsfw_detect": iter_nsfw_detect,
    "violence_images": iter_violence_images,
    "UnsafeBench": iter_unsafebench,
}


def iter_all(sources: list[str] | None = None) -> Iterator[RawRecord]:
    """Yield records from the requested sources (all sources by default)."""
    names = sources or list(READERS)
    for name in names:
        reader = READERS.get(name)
        if reader is None:
            raise KeyError(f"unknown source: {name}")
        yield from reader()
