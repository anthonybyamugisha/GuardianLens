"""Stage 6 - Model definition.

A compact, from-scratch convolutional network in the spirit of MobileNetV2:
an inverted-residual (depthwise-separable) backbone with a lightweight
classifier head. It is intentionally small (< ~2.5M params) so it exports to
a few-megabyte TFLite model that runs on-device.

TensorFlow is imported lazily so this module can be imported without TF.

Usage:
    python -m src.model            # prints the model summary
"""
from __future__ import annotations

import config


def _conv_bn(x, filters, kernel=3, stride=1, activation="relu6"):
    from tensorflow.keras import layers

    x = layers.Conv2D(
        filters, kernel, strides=stride, padding="same", use_bias=False
    )(x)
    x = layers.BatchNormalization()(x)
    if activation:
        x = layers.Activation(activation)(x)
    return x


def _inverted_residual(x, filters, stride, expand=6):
    """MobileNetV2-style block: expand -> depthwise -> project (+ residual)."""
    from tensorflow.keras import layers

    in_channels = x.shape[-1]
    hidden = max(filters, int(round(in_channels * expand)))
    y = _conv_bn(x, hidden, kernel=1, stride=1)
    y = layers.DepthwiseConv2D(3, strides=stride, padding="same", use_bias=False)(y)
    y = layers.BatchNormalization()(y)
    y = layers.Activation("relu6")(y)
    y = layers.Conv2D(filters, 1, padding="same", use_bias=False)(y)
    y = layers.BatchNormalization()(y)
    if stride == 1 and in_channels == filters:
        y = layers.Add()([x, y])
    return y


def build_model(image_size: int = config.IMAGE_SIZE, num_classes: int = config.NUM_CLASSES):
    """Construct and return the (uncompiled) Keras model."""
    from tensorflow.keras import Model, layers

    inputs = layers.Input(shape=(image_size, image_size, config.CHANNELS), name="image")
    x = _conv_bn(inputs, 32, kernel=3, stride=2)          # 112
    x = _conv_bn(x, 32, kernel=3, stride=1)

    # Inverted-residual backbone: (filters, stride, expansion).
    for filters, stride, expand in [
        (16, 1, 1),
        (24, 2, 6),
        (24, 1, 6),
        (32, 2, 6),
        (32, 1, 6),
        (64, 2, 6),
        (64, 1, 6),
        (96, 2, 6),
        (96, 1, 6),
        (160, 2, 6),
    ]:
        x = _inverted_residual(x, filters, stride, expand)

    x = _conv_bn(x, 256, kernel=1, stride=1)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)

    if num_classes == 2:
        outputs = layers.Dense(1, activation="sigmoid", name="unsafe")(x)
    else:
        outputs = layers.Dense(num_classes, activation="softmax", name="class")(x)

    return Model(inputs, outputs, name="guardianlens_moderator")


if __name__ == "__main__":
    model = build_model()
    model.summary()
