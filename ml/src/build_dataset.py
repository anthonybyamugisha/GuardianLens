"""Orchestrator for stages 1 through 8.

Runs acquire -> normalize -> composite -> split in order and writes the
final ImageFolder dataset used for training.

Usage (planned):
    python -m src.build_dataset --manifest manifests/sources.json

Status: scaffold. Implementation pending pipeline decisions.
"""
