"""Stage 7 - Evaluation.

Loads a trained model, runs it over the test split and reports accuracy,
precision, recall, F1, ROC-AUC and a confusion matrix. Metrics are written
to ``models/eval_metrics.json``.

Usage:
    python -m src.evaluate
    python -m src.evaluate --model models/moderator.keras
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import config
from src import build_dataset


def _confusion(y_true, y_pred):
    import tensorflow as tf

    return tf.math.confusion_matrix(y_true, y_pred, num_classes=config.NUM_CLASSES).numpy()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, default=config.MODEL_DIR / "moderator.keras")
    parser.add_argument("--batch-size", type=int, default=config.BATCH_SIZE)
    parser.add_argument("--threshold", type=float, default=0.5)
    parser.add_argument(
        "--out", type=Path, default=config.MODEL_DIR / "eval_metrics.json"
    )
    args = parser.parse_args()

    import numpy as np
    import tensorflow as tf

    paths = build_dataset.split_paths()
    _, y_true = build_dataset.read_split(paths["test"])
    test_ds = build_dataset.make_dataset(
        paths["test"], training=False, batch_size=args.batch_size, shuffle=False
    )

    net = tf.keras.models.load_model(args.model)
    scores = net.predict(test_ds).reshape(-1)
    y_true = np.asarray(y_true)

    if config.NUM_CLASSES == 2:
        y_pred = (scores >= args.threshold).astype(int)
    else:
        y_pred = scores.argmax(axis=-1)

    matrix = _confusion(y_true, y_pred)
    tp = int(matrix[1, 1])
    tn = int(matrix[0, 0])
    fp = int(matrix[0, 1])
    fn = int(matrix[1, 0])

    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    accuracy = (tp + tn) / int(matrix.sum())
    auc = float(
        tf.keras.metrics.AUC()(y_true, scores).numpy()
    ) if config.NUM_CLASSES == 2 else None

    metrics = {
        "accuracy": round(accuracy, 4),
        "precision": round(precision, 4),
        "recall": round(recall, 4),
        "f1": round(f1, 4),
        "auc": round(auc, 4) if auc is not None else None,
        "confusion_matrix": matrix.tolist(),
        "support": {"total": int(matrix.sum()), "unsafe": tp + fn, "safe": tn + fp},
    }

    print("== test metrics ==")
    for key in ("accuracy", "precision", "recall", "f1", "auc"):
        print(f"  {key:<10} {metrics[key]}")
    print("  confusion (rows=true, cols=pred):")
    for label, row in zip(config.CLASSES, matrix):
        print(f"    {label:<8} {row.tolist()}")

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    print(f"wrote metrics -> {args.out}")


if __name__ == "__main__":
    main()
