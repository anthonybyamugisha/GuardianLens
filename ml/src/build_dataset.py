"""Stage 5 - tf.data input pipeline.

Turns the split CSVs into batched ``tf.data.Dataset`` objects ready for
Keras. Images are decoded, resized to ``config.IMAGE_SIZE`` and scaled to
``[0, 1]``; the training dataset additionally gets light augmentation.

TensorFlow is imported lazily so the rest of the pipeline can be inspected
or run without it installed.

Usage:
    python -m src.build_dataset            # prints the shapes of each split
"""
from __future__ import annotations

import csv
from pathlib import Path

import config

SPLIT_NAMES = ("train", "val", "test")


def split_paths(out_dir: Path | None = None) -> dict[str, Path]:
    base = out_dir or config.SPLIT_DIR
    return {name: base / f"{name}.csv" for name in SPLIT_NAMES}


def read_split(path: Path) -> tuple[list[str], list[int]]:
    paths: list[str] = []
    labels: list[int] = []
    with Path(path).open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            paths.append(row["path"])
            labels.append(config.CLASSES.index(row["label"]))
    return paths, labels


def _augment(image, image_size):
    import tensorflow as tf

    image = tf.image.random_flip_left_right(image)
    image = tf.image.random_brightness(image, max_delta=0.15)
    image = tf.image.random_contrast(image, lower=0.85, upper=1.15)
    # Random crop-and-resize (scale jitter) for translation invariance.
    zoom = tf.random.uniform([], 0.85, 1.0)
    crop = tf.cast(tf.cast(image_size, tf.float32) * zoom, tf.int32)
    image = tf.image.random_crop(image, [crop, crop, config.CHANNELS])
    image = tf.image.resize(image, [image_size, image_size])
    return tf.clip_by_value(image, 0.0, 1.0)


def _load_image(path, label, image_size, training):
    import tensorflow as tf

    raw = tf.io.read_file(path)
    image = tf.io.decode_image(raw, channels=config.CHANNELS, expand_animations=False)
    image = tf.image.resize(image, [image_size, image_size])
    image = tf.cast(image, tf.float32) / 255.0
    if training:
        image = _augment(image, image_size)
    return image, label


def make_dataset(
    split_path: Path,
    training: bool = False,
    batch_size: int = config.BATCH_SIZE,
    image_size: int = config.IMAGE_SIZE,
    shuffle: bool | None = None,
):
    """Build a batched, prefetched ``tf.data.Dataset`` from a split CSV."""
    import tensorflow as tf

    paths, labels = read_split(split_path)
    dataset = tf.data.Dataset.from_tensor_slices((paths, labels))
    do_shuffle = training if shuffle is None else shuffle
    if do_shuffle:
        dataset = dataset.shuffle(len(paths), seed=config.SEED, reshuffle_each_iteration=True)

    dataset = dataset.map(
        lambda path, label: _load_image(path, label, image_size, training),
        num_parallel_calls=tf.data.AUTOTUNE,
    )
    return dataset.batch(batch_size).prefetch(tf.data.AUTOTUNE)


def main() -> None:
    print("== input pipeline ==")
    for name, path in split_paths().items():
        dataset = make_dataset(path, training=(name == "train"), shuffle=False)
        images, labels = next(iter(dataset))
        print(
            f"  {name:<6} batch={tuple(images.shape)} "
            f"range=[{float(images.numpy().min()):.2f},{float(images.numpy().max()):.2f}]"
        )


if __name__ == "__main__":
    main()
