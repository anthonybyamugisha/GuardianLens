"""Central configuration for the GuardianLens moderation dataset pipeline.

Everything configurable (paths, image size, split ratios, label taxonomy)
lives here so the rest of the pipeline stays declarative.
"""
from __future__ import annotations

from pathlib import Path

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
ML_ROOT = Path(__file__).resolve().parent
RAW_DIR = ML_ROOT / "data" / "raw"
EXTRACT_DIR = ML_ROOT / "data" / "extracted"

# Intermediate outputs of the pipeline stages.
CLEAN_DIR = ML_ROOT / "data" / "cleaned"
PROCESSED_DIR = ML_ROOT / "data" / "processed"
SPLIT_DIR = ML_ROOT / "data" / "splits"
MANIFEST_DIR = ML_ROOT / "manifests"
MODEL_DIR = ML_ROOT / "models"

# Manifest files produced by the pipeline.
RAW_INDEX = MANIFEST_DIR / "raw_index.csv"
CLEAN_INDEX = MANIFEST_DIR / "clean_index.csv"
PROCESSED_INDEX = MANIFEST_DIR / "processed_index.csv"

# ---------------------------------------------------------------------------
# Image / training hyperparameters
# ---------------------------------------------------------------------------
IMAGE_SIZE = 224            # square input, matches the on-device model
CHANNELS = 3
SEED = 42

SPLIT_RATIOS = {"train": 0.8, "val": 0.1, "test": 0.1}

BATCH_SIZE = 32
EPOCHS = 40
LEARNING_RATE = 1e-3

MIN_IMAGE_SIZE = 64         # drop anything smaller than this (either side)

# ---------------------------------------------------------------------------
# Label taxonomy
# ---------------------------------------------------------------------------
# Target classes produced by the pipeline. Binary is what an on-device
# moderation gate needs; per-source categories are kept as metadata so a
# multi-class variant can be added later without re-cleaning the data.
CLASSES = ["safe", "unsafe"]
NUM_CLASSES = len(CLASSES)

# Map each source's native labels onto our target classes.
TAXONOMY: dict[str, dict[str, str]] = {
    # deepghs/nsfw_detect: drawings + neutral are treated as safe.
    "nsfw_detect": {
        "neutral": "safe",
        "drawings": "safe",
        "sexy": "unsafe",
        "hentai": "unsafe",
        "porn": "unsafe",
    },
    # yiting/UnsafeBench: direct safe/unsafe label.
    "UnsafeBench": {
        "Safe": "safe",
        "Unsafe": "unsafe",
    },
    # ChinaZhangPeng/Violence-Image-Dataset: every image depicts violence.
    "violence_images": {
        "violence": "unsafe",
    },
}


def map_label(source: str, raw_label: str) -> str | None:
    """Resolve a source-native label to a target class (None if unknown)."""
    return TAXONOMY.get(source, {}).get(raw_label)
