"""Stage 6 - Training.

Builds the tf.data datasets, compiles the model and fits it, using class
weights to compensate for the safe/unsafe imbalance. The best checkpoint
(by validation AUC) is saved to ``models/``.

Usage:
    python -m src.train
    python -m src.train --epochs 60 --batch-size 64
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import config
from src import build_dataset, model

try:  # TensorFlow is optional at import time so the module stays inspectable.
    import tensorflow as tf
except ImportError:  # pragma: no cover - dependency guard
    tf = None


def class_weights(path: Path) -> dict[int, float]:
    _, labels = build_dataset.read_split(path)
    counts = [0] * config.NUM_CLASSES
    for label in labels:
        counts[label] += 1
    return {
        index: len(labels) / (config.NUM_CLASSES * count)
        for index, count in enumerate(counts)
        if count
    }


def build_callbacks(model_path: Path):
    from tensorflow.keras import callbacks

    return [
        callbacks.ModelCheckpoint(
            model_path, monitor="val_auc", mode="max", save_best_only=True, verbose=1
        ),
        callbacks.EarlyStopping(
            monitor="val_auc", mode="max", patience=6, restore_best_weights=True
        ),
        callbacks.ReduceLROnPlateau(
            monitor="val_loss", factor=0.5, patience=3, min_lr=1e-6, verbose=1
        ),
    ]


def compile_model(model, learning_rate: float):
    import tensorflow as tf

    if config.NUM_CLASSES == 2:
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate),
            loss="binary_crossentropy",
            metrics=[
                "accuracy",
                tf.keras.metrics.AUC(name="auc"),
                tf.keras.metrics.Precision(name="precision"),
                tf.keras.metrics.Recall(name="recall"),
            ],
        )
    else:
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate),
            loss="sparse_categorical_crossentropy",
            metrics=["accuracy"],
        )
    return model


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--epochs", type=int, default=config.EPOCHS)
    parser.add_argument("--batch-size", type=int, default=config.BATCH_SIZE)
    parser.add_argument("--image-size", type=int, default=config.IMAGE_SIZE)
    parser.add_argument("--alpha", type=float, default=config.MOBILENET_ALPHA)
    parser.add_argument("--lr", type=float, default=config.LEARNING_RATE)
    parser.add_argument("--out", type=Path, default=config.MODEL_DIR / "moderator.keras")
    args = parser.parse_args()

    import tensorflow as tf

    tf.keras.utils.set_random_seed(config.SEED)

    paths = build_dataset.split_paths()
    train_ds = build_dataset.make_dataset(
        paths["train"], training=True, batch_size=args.batch_size, image_size=args.image_size
    )
    val_ds = build_dataset.make_dataset(
        paths["val"], training=False, batch_size=args.batch_size, image_size=args.image_size
    )

    weights = class_weights(paths["train"])
    print("class weights:", weights)

    net = model.build_model(image_size=args.image_size, alpha=args.alpha)
    compile_model(net, args.lr)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    net.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        class_weight=weights,
        callbacks=build_callbacks(args.out),
    )

    net.save(args.out)
    print(f"saved model -> {args.out}")


if __name__ == "__main__":
    main()
