"""Stage 1 - Acquire raw datasets.

Reads manifests/sources.json and downloads each dataset into
data/raw/<name>/. Downloads raw bytes only; no preprocessing happens here.

Usage:
    python -m src.acquire --list          # show datasets and core flag
    python -m src.acquire                 # download core datasets
    python -m src.acquire --all           # download every dataset
    python -m src.acquire --only nsfw_detect UnsafeBench
"""
from __future__ import annotations

import argparse
import json
import os
import zipfile
from pathlib import Path
from urllib.request import urlretrieve

ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
DEFAULT_MANIFEST = ROOT / "manifests" / "sources.json"


def load_manifest(path: Path) -> dict:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def download_huggingface(ds: dict, dest: Path) -> Path:
    from huggingface_hub import snapshot_download

    dest.mkdir(parents=True, exist_ok=True)
    allow = ds.get("allow_patterns")
    snapshot_download(
        repo_id=ds["id"],
        repo_type="dataset",
        local_dir=str(dest),
        allow_patterns=allow,
        token=os.environ.get("HF_TOKEN"),
    )
    return dest


def download_github_zip(ds: dict, dest: Path) -> Path:
    branch = ds.get("branch", "main")
    url = f"https://github.com/{ds['id']}/archive/refs/heads/{branch}.zip"
    dest.mkdir(parents=True, exist_ok=True)
    zip_path = dest / f"{ds['name']}.zip"
    print(f"    GET {url}")
    urlretrieve(url, zip_path)
    with zipfile.ZipFile(zip_path) as archive:
        archive.extractall(dest)
    zip_path.unlink()
    return dest


def download(ds: dict) -> Path:
    dest = RAW_DIR / ds["name"]
    source = ds["source"]
    if source == "huggingface":
        return download_huggingface(ds, dest)
    if source == "github":
        return download_github_zip(ds, dest)
    raise ValueError(f"unknown source: {source}")


def select(datasets: list[dict], only: list[str] | None, include_all: bool) -> list[dict]:
    if only:
        wanted = {n.lower() for n in only}
        return [d for d in datasets if d["name"].lower() in wanted]
    if include_all:
        return datasets
    return [d for d in datasets if d.get("core")]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--only", nargs="+", help="dataset names to download")
    parser.add_argument("--all", action="store_true", help="download every dataset")
    parser.add_argument("--list", action="store_true", help="list datasets and exit")
    args = parser.parse_args()

    manifest = load_manifest(args.manifest)
    datasets = manifest["datasets"]

    if args.list:
        for ds in datasets:
            flag = "core" if ds.get("core") else "later"
            print(f"  [{flag:5}] {ds['name']:28} {ds['source']:11} {ds['id']}")
        return

    targets = select(datasets, args.only, args.all)
    if not targets:
        print("No datasets selected.")
        return

    for ds in targets:
        print(f"==> {ds['name']} ({ds['source']}: {ds['id']})")
        try:
            path = download(ds)
            print(f"    done -> {path}")
        except Exception as exc:  # noqa: BLE001 - report and continue
            print(f"    FAILED: {type(exc).__name__}: {str(exc)[:200]}")


if __name__ == "__main__":
    main()
