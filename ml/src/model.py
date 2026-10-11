"""Stage 6 - Model definition.

A MobileNetV2 backbone with a small classification head. MobileNetV2's
depthwise-separable convolutions keep the model small and fast enough for
on-device inference, and its width multiplier (``alpha``) can be lowered to
trade accuracy for speed on weaker phones.

The backbone is created with ``weights=None`` so the network is trained
entirely from scratch on GuardianLens's own dataset; no pretrained (cloud)
weights are downloaded at any point.

TensorFlow is imported lazily so this module can be imported without TF.

Usage:
    python -m src.model                  # prints the model summary
    python -m src.model --alpha 0.5      # smaller/faster variant
"""
from __future__ import annotations

import argparse

import config


def build_model(
    image_size: int = config.IMAGE_SIZE,
    alpha: float = config.MOBILENET_ALPHA,
    num_classes: int = config.NUM_CLASSES,
    dropout: float = config.DROPOUT,
):
    """Build a MobileNetV2-backed binary/multi-class moderation model."""
    from tensorflow.keras import layers, Model
    from tensorflow.keras.applications import MobileNetV2

    backbone = MobileNetV2(
        input_shape=(image_size, image_size, config.CHANNELS),
        alpha=alpha,
        include_top=False,
        weights=None,
    )

    x = layers.GlobalAveragePooling2D()(backbone.output)
    x = layers.Dropout(dropout)(x)

    if num_classes == 2:
        outputs = layers.Dense(1, activation="sigmoid", name="unsafe")(x)
    else:
        outputs = layers.Dense(num_classes, activation="softmax", name="class")(x)

    return Model(backbone.input, outputs, name=f"guardianlens_mobilenetv2_a{alpha}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image-size", type=int, default=config.IMAGE_SIZE)
    parser.add_argument("--alpha", type=float, default=config.MOBILENET_ALPHA)
    args = parser.parse_args()

    net = build_model(image_size=args.image_size, alpha=args.alpha)
    net.summary()
    print(f"parameters: {net.count_params():,}")


if __name__ == "__main__":
    main()
