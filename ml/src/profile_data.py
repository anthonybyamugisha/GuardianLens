"""Profiling helper: summarise the raw datasets before cleaning.

Prints per-source label counts and how each native label maps onto the
target classes. Safe to run without the full ML stack: sources whose reader
needs a missing dependency (e.g. pyarrow for UnsafeBench) report an error
instead of crashing the run.
"""
from __future__ import annotations

import argparse

import config
from src import sources


def profile_source(name: str) -> dict[str, int] | None:
    """Print a per-label breakdown for one source; return mapped counts."""
    reader = sources.READERS.get(name)
    if reader is None:
        print(f"  ! unknown source: {name}")
        return None

    native: dict[str, int] = {}
    mapped: dict[str, int] = {}
    has_unmapped = False
    try:
        for record in reader():
            native[record.raw_label] = native.get(record.raw_label, 0) + 1
            target = config.map_label(record.source, record.raw_label)
            if target is None:
                has_unmapped = True
            else:
                mapped[target] = mapped.get(target, 0) + 1
    except Exception as exc:  # noqa: BLE001 - report and continue
        print(f"  ! {name}: {type(exc).__name__}: {exc}")
        return None

    print(f"  {name}: {sum(native.values())} images")
    for label, count in sorted(native.items(), key=lambda kv: -kv[1]):
        target = config.map_label(name, label) or "(unmapped)"
        print(f"      {label:<12} {count:>7}  -> {target}")
    if has_unmapped:
        print("      ! some labels have no target mapping")
    return mapped


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", nargs="+", help="subset of sources to profile")
    args = parser.parse_args()

    names = args.sources or list(sources.READERS)
    totals: dict[str, int] = {}
    for name in names:
        print(f"\n[{name}]")
        mapped = profile_source(name)
        if mapped:
            for label, count in mapped.items():
                totals[label] = totals.get(label, 0) + count

    print("\n== summary ==")
    for label in config.CLASSES:
        print(f"  {label:<8} {totals.get(label, 0)}")
    print(f"  {'total':<8} {sum(totals.values())}")


if __name__ == "__main__":
    main()
