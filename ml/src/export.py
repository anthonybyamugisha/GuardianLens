"""Stage 8 - Export to TensorFlow Lite.

Converts the trained Keras model to ``.tflite`` for the on-device child
agent. Quantisation options trade size/accuracy:

* ``none``     - float32, largest, most accurate
* ``float16``  - ~2x smaller, minimal accuracy loss, float I/O
* ``dynamic``  - dynamic-range int8 weights, integer input, float I/O
* ``int8``     - full integer, smallest, needs a representative dataset

Usage:
    python -m src.export --quant float16
    python -m src.export --quant int8
"""
from __future__ import annotations

import argparse
from pathlib import Path

import config
from src import build_dataset


def representative_dataset(samples: int = 100):
    dataset = build_dataset.make_dataset(
        build_dataset.split_paths()["train"], training=False, batch_size=1, shuffle=True
    )
    for images, _ in dataset.take(samples):
        yield [images]


def convert(model_path: Path, quant: str, image_size: int):
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
        converter.representative_dataset = representative_dataset
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.int8
        converter.inference_output_type = tf.int8

    return converter.convert()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, default=config.MODEL_DIR / "moderator.keras")
    parser.add_argument("--out", type=Path, default=config.MODEL_DIR / "moderator.tflite")
    parser.add_argument(
        "--quant", choices=["none", "float16", "dynamic", "int8"], default="float16"
    )
    parser.add_argument("--image-size", type=int, default=config.IMAGE_SIZE)
    args = parser.parse_args()

    buffer = convert(args.model, args.quant, args.image_size)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_bytes(buffer)
    print(f"wrote {args.quant} model -> {args.out} ({len(buffer) / 1e6:.2f} MB)")


if __name__ == "__main__":
    main()
