"""Evaluate the saved real-data CNN on Synthetic Dataset/test only."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import tensorflow as tf

ROOT = Path(__file__).resolve().parent.parent
MODEL_PATH = ROOT / "models" / "banana_cnn_drive.keras"
DATA_DIR = Path(
    r"G:\.shortcut-targets-by-id\1AI7SzEx1Y6mTJAbThxljTH7OK8BntuUO"
    r"\Banana Images\Synthetic Dataset"
)
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16
EXPECTED_CLASSES = ["Grade A", "Grade B", "Grade C", "Grade D"]


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Evaluate banana_cnn_drive.keras on Synthetic Dataset/test only."
    )
    parser.add_argument("--data-dir", type=Path, default=DATA_DIR,
                        help="Synthetic Dataset folder containing train/ and test/.")
    parser.add_argument("--model-path", type=Path, default=MODEL_PATH)
    parser.add_argument("--report-path", type=Path,
                        default=ROOT / "models" / "synthetic_evaluation.json")
    args = parser.parse_args()

    data_dir = args.data_dir.expanduser().resolve()
    model_path = args.model_path.expanduser().resolve()
    report_path = args.report_path.expanduser().resolve()
    test_dir = data_dir / "test"

    if not model_path.is_file():
        raise FileNotFoundError(f"Saved model not found: {model_path}")
    if not test_dir.is_dir():
        raise FileNotFoundError(f"Synthetic test folder not found: {test_dir}")

    # Load the held-out synthetic split only; never load Synthetic Dataset/train.
    test_ds = tf.keras.utils.image_dataset_from_directory(
        test_dir,
        class_names=EXPECTED_CLASSES,
        image_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        shuffle=False,
    )
    model = tf.keras.models.load_model(model_path)
    output_classes = model.output_shape[-1]
    if output_classes != len(EXPECTED_CLASSES):
        raise ValueError(
            f"Model outputs {output_classes} classes, expected {len(EXPECTED_CLASSES)}."
        )

    loss, accuracy = model.evaluate(test_ds, verbose=1)
    y_true = tf.concat([labels for _, labels in test_ds], axis=0).numpy()
    probabilities = model.predict(test_ds, verbose=0)
    y_pred = np.argmax(probabilities, axis=1)
    matrix = tf.math.confusion_matrix(
        y_true, y_pred, num_classes=len(EXPECTED_CLASSES)
    ).numpy()

    true_positive = matrix.diagonal().astype(np.float64)
    precision = true_positive / np.maximum(matrix.sum(axis=0), 1)
    recall = true_positive / np.maximum(matrix.sum(axis=1), 1)
    f1 = 2 * precision * recall / np.maximum(precision + recall, 1e-12)
    support = matrix.sum(axis=1)
    macro = {
        "precision": float(precision.mean()),
        "recall": float(recall.mean()),
        "f1_score": float(f1.mean()),
    }
    weighted = {
        "precision": float(np.average(precision, weights=support)),
        "recall": float(np.average(recall, weights=support)),
        "f1_score": float(np.average(f1, weights=support)),
    }

    print(f"Model: {model_path}")
    print(f"Test data: {test_dir}")
    print(f"Classes (label order): {test_ds.class_names}")
    print(f"Test images: {int(support.sum())}")
    print(f"Test loss: {loss:.4f}; accuracy: {accuracy:.4f} ({accuracy:.2%})")
    print("\nClassification report:")
    print(f"{'Class':<12} {'Precision':>10} {'Recall':>10} {'F1-score':>10} {'Support':>9}")
    for index, name in enumerate(EXPECTED_CLASSES):
        print(f"{name:<12} {precision[index]:>10.4f} {recall[index]:>10.4f} "
              f"{f1[index]:>10.4f} {support[index]:>9}")
    print(f"{'Macro avg':<12} {macro['precision']:>10.4f} {macro['recall']:>10.4f} "
          f"{macro['f1_score']:>10.4f} {support.sum():>9}")
    print(f"{'Weighted avg':<12} {weighted['precision']:>10.4f} {weighted['recall']:>10.4f} "
          f"{weighted['f1_score']:>10.4f} {support.sum():>9}")
    print("\nConfusion matrix (rows=actual, columns=predicted):")
    print("             " + "  ".join(f"{name:>8}" for name in EXPECTED_CLASSES))
    for name, row in zip(EXPECTED_CLASSES, matrix):
        print(f"{name:<12} " + "  ".join(f"{int(value):>8}" for value in row))

    report = {
        "model": str(model_path),
        "test_dir": str(test_dir),
        "class_names": EXPECTED_CLASSES,
        "image_size": list(IMAGE_SIZE),
        "batch_size": BATCH_SIZE,
        "test_images": int(support.sum()),
        "loss": float(loss),
        "accuracy": float(accuracy),
        "per_class": {
            name: {
                "precision": float(precision[i]),
                "recall": float(recall[i]),
                "f1_score": float(f1[i]),
                "support": int(support[i]),
            }
            for i, name in enumerate(EXPECTED_CLASSES)
        },
        "macro_average": macro,
        "weighted_average": weighted,
        "confusion_matrix": matrix.tolist(),
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"\nJSON report saved to: {report_path}")


if __name__ == "__main__":
    main()
