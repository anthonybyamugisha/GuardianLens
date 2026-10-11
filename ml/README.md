# GuardianLens ML Workspace

Offline, on-device visual moderation model for the GuardianLens child agent.

The goal is a small, fast image classifier that runs on the device (no cloud API)
and flags potentially inappropriate screen content in monitored applications.

## Pipeline

```
[1] acquire   -> [2] normalize -> [3] map labels -> [4] clean/dedupe
                                                          |
[8] export    <- [7] split     <- [6] balance    <- [5] composite (domain match)
   |
   v
[9] train (from scratch) -> [10] quantize -> TFLite -> [11] evaluate on device
```

| Stage | Module | Output |
|-------|--------|--------|
| 1 Acquire | `src/acquire.py` | `data/raw/<dataset>/` |
| 2 Normalize | `src/normalize.py` | `data/processed/<dataset>/` |
| 3-4 Map + clean | `src/normalize.py` | unified records |
| 5 Composite | `src/composite.py` | screen-like frames |
| 6-7 Balance + split | `src/split.py` | `data/splits/{train,val,test}/` |
| 8-9 Build + train | `src/build_dataset.py`, `src/train.py` | `models/*.keras` |
| 10 Quantize | `src/convert_tflite.py` | `models/*.tflite` |

`src/build_dataset.py` orchestrates stages 1 through 8.

## Layout

```
ml/
├── data/
│   ├── raw/         # downloaded datasets (gitignored)
│   ├── processed/   # normalized / composited (gitignored)
│   └── splits/      # train/val/test ImageFolder (gitignored)
├── src/             # pipeline code
├── models/          # trained artifacts (gitignored)
└── manifests/       # dataset provenance (tracked)
```

## Data sources

See `manifests/sources.json` for the full manifest (name, id, license, use).

- Unsafe: `yiting/UnsafeBench`, `deepghs/nsfw_detect`, GantMan `nsfw_model`, violence image set
- Safe: Rico screenshots, RICO-ScreenAnnotation-f, Enrico

## Notes

- Images only; no video (keeps capture/inference fast).
- Never collect or use imagery of real minors. See the project ethics section.
- Raw/processed data and model binaries are gitignored; only code and manifests are tracked.
