# GuardianLens ML Workspace

Offline, on-device visual moderation model for the GuardianLens child agent.

The goal is a small, fast image classifier that runs on the device (no cloud
API) and flags potentially inappropriate screen content. Everything here is
trained from scratch with TensorFlow/Keras and exported to TensorFlow Lite.

## Pipeline

```
[1] acquire -> [2] clean -> [3] preprocess -> [4] split
                                                 |
[8] export  <- [7] evaluate <- [6] train   <- [5] tf.data pipeline
```

| Stage | Module | Output |
|-------|--------|--------|
| 1 Acquire | `src/acquire.py` | `data/raw/<dataset>/` |
| - Profile | `src/profile_data.py` | label counts (stdout) |
| 2 Clean | `src/cleaning.py` | `manifests/clean_index.csv` |
| 3 Preprocess | `src/normalize.py` | `data/processed/`, `manifests/processed_index.csv` |
| 4 Split | `src/split.py` | `data/splits/{train,val,test}.csv` |
| 5 Input pipeline | `src/build_dataset.py` | `tf.data.Dataset` |
| 6 Model | `src/model.py` | compact MobileNetV2-style CNN |
| 6 Train | `src/train.py` | `models/moderator.keras` |
| 7 Evaluate | `src/evaluate.py` | `models/eval_metrics.json` |
| 8 Export | `src/export.py` | `models/moderator.tflite` |

## Run order

```bash
# from ml/, with the venv python
python -m src.acquire                 # download raw datasets
python -m src.profile_data            # inspect labels
python -m src.cleaning                # drop corrupt / small / duplicate images
python -m src.normalize               # resize to 224x224 JPEGs
python -m src.split                   # 80/10/10 train/val/test
python -m src.train                   # train from scratch
python -m src.evaluate                # test metrics
python -m src.export --quant float16  # TFLite for the device
```

## Labels

Binary target produced by the pipeline: `safe` / `unsafe`. Native source
labels are mapped in `config.TAXONOMY`; per-source categories are retained
in the manifests so a multi-class variant can be added later.

## Layout

```
ml/
├── config.py        # paths, hyperparameters, label taxonomy
├── data/
│   ├── raw/         # downloaded datasets (gitignored)
│   ├── extracted/   # unpacked archives / parquet images (gitignored)
│   ├── cleaned/     # reserved (gitignored)
│   ├── processed/   # resized JPEGs (gitignored)
│   └── splits/      # train/val/test CSVs (gitignored)
├── src/             # pipeline code
├── models/          # trained artifacts (gitignored)
└── manifests/       # sources.json (tracked); *_index.csv (ignored)
```

## Data sources

See `manifests/sources.json` for the full manifest (name, id, license, use).

- Unsafe: `yiting/UnsafeBench`, `deepghs/nsfw_detect`, violence image set
- Safe: served by the `neutral` / `drawings` classes above
- Later: Rico / RICO-ScreenAnnotation-f / Enrico (app-screenshot domain)

## Notes

- Images only (no video); the on-device model must be small and fast.
- Never use imagery of real minors.
- Raw data, processed data and model artifacts are gitignored; only code,
  config and `manifests/sources.json` are tracked.
