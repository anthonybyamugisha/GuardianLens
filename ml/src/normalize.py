"""Stage 3 - Preprocessing (normalisation).

Reads ``manifests/clean_index.csv`` and turns every cleaned image into a
uniform, model-ready JPEG:

* decode and convert to RGB (handles greyscale / CMYK / RGBA inputs),
* resize the shorter side so the image covers ``config.IMAGE_SIZE`` and
  centre-crop to a square (no aspect-ratio distortion),
* write to ``data/processed/<label>/<source>_<id>.jpg``,
* emit ``manifests/processed_index.csv`` for the split stage.

Pixel scaling/augmentation happen in the input pipeline (``build_dataset.py``),
not here, so the processed files stay human-inspectable.

Usage:
    python -m src.normalize                 # use manifests/clean_index.csv
    python -m src.normalize --size 256
    python -m src.normalize --limit 50      # smoke test
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path

from PIL import Image
from tqdm import tqdm

import config

FIELDS = ["path", "source", "raw_label", "label", "category", "width", "height", "md5"]


def _load_index(path: Path) -> list[dict]:
    with Path(path).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def _cover_square(image: Image.Image, size: int) -> Image.Image:
    """Resize so the shorter side equals ``size``, then centre-crop square."""
    width, height = image.size
    scale = size / min(width, height)
    new_size = (max(size, round(width * scale)), max(size, round(height * scale)))
    image = image.resize(new_size, Image.BICUBIC)
    left = (image.width - size) // 2
    top = (image.height - size) // 2
    return image.crop((left, top, left + size, top + size))


def normalise(
    index_path: Path,
    out_dir: Path,
    size: int,
    quality: int,
    limit: int | None,
) -> list[dict]:
    rows = _load_index(index_path)
    if limit:
        rows = rows[:limit]

    out_dir.mkdir(parents=True, exist_ok=True)
    processed: list[dict] = []
    skipped = 0

    for row in tqdm(rows, desc="preprocessing", unit="img"):
        src = Path(row["path"])
        label = row["label"]
        dest_dir = out_dir / label
        dest_dir.mkdir(parents=True, exist_ok=True)
        dest = dest_dir / f"{row['source']}_{row['md5'][:16]}.jpg"
        try:
            with Image.open(src) as image:
                square = _cover_square(image.convert("RGB"), size)
                square.save(dest, "JPEG", quality=quality)
        except Exception:  # noqa: BLE001 - leftover corrupt file, skip
            skipped += 1
            continue

        processed.append(
            {
                "path": str(dest),
                "source": row["source"],
                "raw_label": row["raw_label"],
                "label": label,
                "category": row["category"],
                "width": row["width"],
                "height": row["height"],
                "md5": row["md5"],
            }
        )

    return processed, skipped


def write_index(rows: list[dict], out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--index", type=Path, default=config.CLEAN_INDEX)
    parser.add_argument("--out-dir", type=Path, default=config.PROCESSED_DIR)
    parser.add_argument("--out-index", type=Path, default=config.PROCESSED_INDEX)
    parser.add_argument("--size", type=int, default=config.IMAGE_SIZE)
    parser.add_argument("--quality", type=int, default=90)
    parser.add_argument("--limit", type=int, help="only process the first N rows")
    args = parser.parse_args()

    rows, skipped = normalise(
        args.index, args.out_dir, args.size, args.quality, args.limit
    )
    write_index(rows, args.out_index)

    counts: dict[str, int] = {}
    for row in rows:
        counts[row["label"]] = counts.get(row["label"], 0) + 1
    print(f"\nwrote {len(rows)} images -> {args.out_dir}")
    print(f"index -> {args.out_index}  (skipped {skipped})")
    for label in config.CLASSES:
        print(f"  {label:<8} {counts.get(label, 0)}")


if __name__ == "__main__":
    main()
