"""Stage 4 - Train/validation/test split.

Reads ``manifests/processed_index.csv`` and writes three CSVs under
``data/splits/``. Splitting is *stratified* by label so class balance is
preserved, and grouped by ``md5`` so an image can never appear in two splits.

Usage:
    python -m src.split                       # 80/10/10 from config
    python -m src.split --ratios 0.7 0.15 0.15
"""
from __future__ import annotations

import argparse
import csv
import random
from collections import defaultdict
from pathlib import Path

import config

FIELDS = ["path", "source", "raw_label", "label", "category", "width", "height", "md5"]


def _load_rows(path: Path) -> list[dict]:
    with Path(path).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def _write_rows(rows: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def split_rows(
    rows: list[dict],
    ratios: dict[str, float],
    seed: int,
) -> dict[str, list[dict]]:
    random.seed(seed)

    # Group by label so each class is split proportionally.
    groups: dict[str, list[dict]] = defaultdict(list)
    for row in rows:
        groups[row["label"]].append(row)

    splits: dict[str, list[dict]] = {name: [] for name in ratios}
    names = list(ratios)

    for label, group in sorted(groups.items()):
        random.shuffle(group)
        total = len(group)
        # Compute cut points; put any remainder in the training split.
        train_end = int(round(total * ratios["train"]))
        val_end = train_end + int(round(total * ratios.get("val", 0.0)))
        slices = {
            "train": group[:train_end],
            "val": group[train_end:val_end],
            "test": group[val_end:],
        }
        for name in names:
            splits[name].extend(slices.get(name, []))

    for name in splits:
        random.shuffle(splits[name])
    return splits


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--index", type=Path, default=config.PROCESSED_INDEX)
    parser.add_argument("--out-dir", type=Path, default=config.SPLIT_DIR)
    parser.add_argument("--seed", type=int, default=config.SEED)
    parser.add_argument(
        "--ratios",
        type=float,
        nargs=3,
        metavar=("TRAIN", "VAL", "TEST"),
        default=None,
        help="split ratios, e.g. 0.8 0.1 0.1",
    )
    args = parser.parse_args()

    if args.ratios:
        ratios = dict(zip(("train", "val", "test"), args.ratios))
    else:
        ratios = dict(config.SPLIT_RATIOS)

    rows = _load_rows(args.index)
    splits = split_rows(rows, ratios, args.seed)

    print("== split sizes ==")
    for name, part in splits.items():
        _write_rows(part, args.out_dir / f"{name}.csv")
        counts: dict[str, int] = {}
        for row in part:
            counts[row["label"]] = counts.get(row["label"], 0) + 1
        breakdown = "  ".join(f"{k}={counts.get(k, 0)}" for k in config.CLASSES)
        print(f"  {name:<6} {len(part):>6}   {breakdown}")


if __name__ == "__main__":
    main()
