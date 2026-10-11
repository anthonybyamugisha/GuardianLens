"""Stage 2 - Data cleaning.

Walks every raw source and keeps only usable images:

* drops files that Pillow cannot decode (corrupt / truncated),
* drops images smaller than ``config.MIN_IMAGE_SIZE`` on either side,
* drops exact duplicates (identical MD5) within and across sources,
* optionally drops near-duplicates via perceptual hashing (``--phash``).

No images are copied: the result is a manifest (``manifests/clean_index.csv``)
that points at the original files, so downstream stages stay fast and disk
usage is not doubled.

Usage:
    python -m src.cleaning                 # all sources, exact-dupe removal
    python -m src.cleaning --phash         # also perceptual near-dupe removal
    python -m src.cleaning --sources nsfw_detect
"""
from __future__ import annotations

import argparse
import csv
import hashlib
from collections import Counter
from pathlib import Path

from PIL import Image

import config
from src import sources

Image.MAX_IMAGE_PIXELS = None  # trust our own data, avoid decompression-bomb errors

FIELDS = ["path", "source", "raw_label", "label", "category", "width", "height", "md5"]


def _md5(path: Path, chunk: int = 1 << 20) -> str:
    digest = hashlib.md5()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(chunk), b""):
            digest.update(block)
    return digest.hexdigest()


def _inspect(path: Path) -> tuple[int, int] | None:
    """Return (width, height) if the image decodes, else None."""
    try:
        with Image.open(path) as image:
            image.load()
            return image.size
    except Exception:  # noqa: BLE001 - any decode failure means corrupt
        return None


def _phash(path: Path):
    import imagehash

    with Image.open(path) as image:
        return imagehash.phash(image.convert("RGB"))


def clean(
    source_names: list[str] | None,
    use_phash: bool,
    phash_threshold: int,
) -> list[dict]:
    rows: list[dict] = []
    seen_md5: set[str] = set()
    seen_phash: list = []
    stats = Counter()

    for name in source_names or list(sources.READERS):
        reader = sources.READERS.get(name)
        if reader is None:
            print(f"  ! unknown source: {name}")
            continue
        print(f"==> {name}")
        try:
            records = list(reader())
        except Exception as exc:  # noqa: BLE001 - e.g. missing pyarrow
            print(f"    skipped: {type(exc).__name__}: {exc}")
            continue

        for i, record in enumerate(records, 1):
            if i % 2000 == 0:
                print(f"    ...{i}/{len(records)}")
            label = config.map_label(record.source, record.raw_label)
            if label is None:
                stats["unmapped"] += 1
                continue

            size = _inspect(record.path)
            if size is None:
                stats["corrupt"] += 1
                continue
            width, height = size
            if width < config.MIN_IMAGE_SIZE or height < config.MIN_IMAGE_SIZE:
                stats["too_small"] += 1
                continue

            md5 = _md5(record.path)
            if md5 in seen_md5:
                stats["dup_exact"] += 1
                continue

            if use_phash:
                try:
                    phash = _phash(record.path)
                except Exception:  # noqa: BLE001
                    stats["corrupt"] += 1
                    continue
                if any(phash - other <= phash_threshold for other in seen_phash):
                    stats["dup_phash"] += 1
                    continue
                seen_phash.append(phash)

            seen_md5.add(md5)
            stats["kept"] += 1
            stats[f"class:{label}"] += 1
            rows.append(
                {
                    "path": str(record.path),
                    "source": record.source,
                    "raw_label": record.raw_label,
                    "label": label,
                    "category": record.category,
                    "width": width,
                    "height": height,
                    "md5": md5,
                }
            )
    return rows, stats


def write_index(rows: list[dict], out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", nargs="+", help="subset of sources to clean")
    parser.add_argument("--phash", action="store_true", help="also drop near-duplicates")
    parser.add_argument("--phash-threshold", type=int, default=4)
    parser.add_argument("--out", type=Path, default=config.CLEAN_INDEX)
    args = parser.parse_args()

    rows, stats = clean(args.sources, args.phash, args.phash_threshold)
    write_index(rows, args.out)

    print(f"\nwrote {len(rows)} rows -> {args.out}")
    print("== cleaning summary ==")
    for key in ("kept", "corrupt", "too_small", "dup_exact", "dup_phash", "unmapped"):
        if stats[key]:
            print(f"  {key:<10} {stats[key]}")
    for label in config.CLASSES:
        print(f"  class:{label:<6} {stats[f'class:{label}']}")


if __name__ == "__main__":
    main()
