"""Stage 8 - Export to TensorFlow Lite.

Converts the trained Keras model to ``.tflite`` for the on-device child agent.
Quantisation trades size and speed:

* ``none``     - float32, largest, most accurate
* ``float16``  - ~2x smaller, minimal accuracy loss, float I/O (GPU-friendly)
* ``dynamic``  - dynamic-range int8 weights, float I/O
* ``int8``     - full integer, smallest and fastest on CPU, needs a
                 representative dataset and uses integer I/O
* ``all``      - writes float16, dynamic and int8 in a single run

A ``<out stem>_labels.json`` sidecar is written alongside the model with the
class order, input size and input scaling so the app can decode predictions.

Usage:
    python -m src.export --quant float16
    python -m src.export --quant int8 --samples 300
    python -m src.export --quant all
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import config
from src import build_dataset

QUANTS = ("float16", "dynamic", "int8")


def representative_dataset(samples: int = 200):
    dataset = build_dataset.make_dataset(
        build_dataset.split_paths()["train"], training=False, batch_size=1, shuffle=True
    )
    for images, _ in dataset.take(samples):
        yield [images]


def convert(model_path: Path, quant: str, samples: int):
    import tensorflow as tf

    net = tf.keras.models.load_model(model_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(net)

    if quant == "float16":
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
    elif quant == "dynamic":
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
    elif quant == "int8":
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = lambda: representative_dataset(samples)
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.int8
        converter.inference_output_type = tf.int8
    elif quant != "none":
        raise ValueError(f"unknown quantisation: {quant}")

    return converter.convert()


def variant_path(base: Path, quant: str) -> Path:
    return base.with_name(f"{base.stem}_{quant}.tflite")


def write_labels(base: Path) -> Path:
    meta = {
        "classes": config.CLASSES,
        "num_classes": config.NUM_CLASSES,
        "image_size": config.IMAGE_SIZE,
        "input_scaling": "0-1",
    }
    path = base.with_name(f"{base.stem}_labels.json")
    path.write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, default=config.MODEL_DIR / "moderator.keras")
    parser.add_argument("--out", type=Path, default=config.MODEL_DIR / "moderator.tflite")
    parser.add_argument("--quant", choices=("none", *QUANTS, "all"), default="float16")
    parser.add_argument("--samples", type=int, default=200)
    args = parser.parse_args()

    quants = QUANTS if args.quant == "all" else (args.quant,)
    for quant in quants:
        buffer = convert(args.model, quant, args.samples)
        out = variant_path(args.out, quant) if args.quant == "all" else args.out
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_bytes(buffer)
        print(f"wrote {quant:<8} -> {out} ({len(buffer) / 1e6:.2f} MB)")

    print(f"wrote labels   -> {write_labels(args.out)}")


if __name__ == "__main__":
    main()
