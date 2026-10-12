"""Stage 9 - Verify an exported TFLite model.

Loads a ``.tflite`` model with the TensorFlow Lite interpreter and runs it on
held-out test-split images, reporting sample accuracy. Handles both float and
full-integer (int8/uint8) quantised models, so it proves the exported artifact
actually runs on-device inputs.

Usage:
    python -m src.verify_tflite
    python -m src.verify_tflite --model models/moderator_float16.tflite
    python -m src.verify_tflite --samples 50
"""
from __future__ import annotations

import argparse
import csv
import time
from pathlib import Path

import numpy as np
from PIL import Image

import config


def load_split(path: Path) -> list[dict]:
    with Path(path).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def prepare(path: str, size: int) -> np.ndarray:
    image = Image.open(path).convert("RGB").resize((size, size), Image.BICUBIC)
    return np.asarray(image, dtype=np.float32) / 255.0


def quantize_input(image: np.ndarray, details: dict) -> np.ndarray:
    dtype = details["dtype"]
    if dtype in (np.int8, np.uint8):
        scale, zero = details["quantization"]
        image = np.round(image / scale + zero)
        info = np.iinfo(dtype)
        return np.clip(image, info.min, info.max).astype(dtype)
    return image.astype(dtype)


def read_output(output: np.ndarray, details: dict) -> float:
    if details["dtype"] in (np.int8, np.uint8):
        scale, zero = details["quantization"]
        output = (output.astype(np.float32) - zero) * scale
    return float(output.reshape(-1)[0])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--model", type=Path, default=config.MODEL_DIR / "moderator_int8.tflite"
    )
    parser.add_argument("--split", type=Path, default=config.SPLIT_DIR / "test.csv")
    parser.add_argument("--samples", type=int, default=20)
    args = parser.parse_args()

    import tensorflow as tf

    interpreter = tf.lite.Interpreter(model_path=str(args.model))
    interpreter.allocate_tensors()
    inp = interpreter.get_input_details()[0]
    out = interpreter.get_output_details()[0]
    _, height, width, _ = inp["shape"]

    rows = load_split(args.split)[: args.samples]
    correct = 0
    elapsed = 0.0
    print(f"model  : {args.model.name}")
    print(f"input  : {np.dtype(inp['dtype']).name} {tuple(inp['shape'])}")
    print(f"output : {out['dtype']} quant={out['quantization']}")
    for row in rows:
        image = prepare(row["path"], height)
        interpreter.set_tensor(inp["index"], quantize_input(image[None, ...], inp))
        start = time.perf_counter()
        interpreter.invoke()
        elapsed += time.perf_counter() - start
        probability = read_output(interpreter.get_tensor(out["index"]), out)
        predicted = "unsafe" if probability >= 0.5 else "safe"
        if predicted == row["label"]:
            correct += 1
    print(f"samples : {len(rows)}")
    print(f"accuracy: {correct}/{len(rows)} = {correct / len(rows):.2%}")
    print(f"latency : {elapsed / len(rows) * 1000:.1f} ms/image (CPU interpreter)")


if __name__ == "__main__":
    main()
