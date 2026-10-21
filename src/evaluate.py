"""Evaluate the saved CNN on the held-out test split."""
from pathlib import Path
import argparse
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "dataset" / "prepared"
MODEL_PATH = ROOT / "models" / "banana_cnn.keras"
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", type=Path, default=DATA_DIR)
    parser.add_argument("--model-path", type=Path, default=MODEL_PATH)
    parser.add_argument("--plot-path", type=Path, default=ROOT / "models" / "evaluation_metrics.png")
    args = parser.parse_args()
    data_dir, model_path, plot_path = args.data_dir.resolve(), args.model_path.resolve(), args.plot_path.resolve()
    if not model_path.is_file():
        raise FileNotFoundError(f"Saved model not found: {model_path}")
    test_dir = data_dir / "test"
    if not test_dir.is_dir():
        raise FileNotFoundError(f"Test split not found: {test_dir}")
    ds = tf.keras.utils.image_dataset_from_directory(
        test_dir, image_size=IMAGE_SIZE, batch_size=BATCH_SIZE, shuffle=False)
    model = tf.keras.models.load_model(model_path)
    loss, accuracy = model.evaluate(ds, verbose=1)
    labels = tf.concat([y for _, y in ds], axis=0)
    predictions = tf.argmax(model.predict(ds, verbose=0), axis=1, output_type=labels.dtype)
    matrix = tf.math.confusion_matrix(labels, predictions, num_classes=len(ds.class_names)).numpy()
    tp = matrix.diagonal().astype("float64")
    precision = tp / (matrix.sum(axis=0) + 1e-12)
    recall = tp / (matrix.sum(axis=1) + 1e-12)
    f1 = 2 * precision * recall / (precision + recall + 1e-12)
    print(f"Test loss: {loss:.4f}; accuracy: {accuracy:.4f}")
    for i, name in enumerate(ds.class_names):
        print(f"{name}: precision={precision[i]:.4f}, recall={recall[i]:.4f}, F1={f1[i]:.4f}")
    print(f"Macro average: precision={precision.mean():.4f}, recall={recall.mean():.4f}, F1={f1.mean():.4f}")
    print("\nGrafik metrik (setiap # sekitar 5%):")
    for i, name in enumerate(ds.class_names):
        bars = "  ".join(f"{metric:<9} {'#' * round(value * 20):<20} {value:6.1%}"
                         for metric, value in (("Precision", precision[i]),
                                               ("Recall", recall[i]),
                                               ("F1", f1[i])))
        print(f"{name}: {bars}")
    print("Confusion matrix (baris=label asli, kolom=prediksi):")
    print(matrix)

    # Save an at-a-glance visualization of class metrics and prediction errors.
    fig, (ax_metrics, ax_cm) = plt.subplots(1, 2, figsize=(13, 5.5), constrained_layout=True)
    x = np.arange(len(ds.class_names))
    width = 0.24
    ax_metrics.bar(x - width, precision, width, label="Precision")
    ax_metrics.bar(x, recall, width, label="Recall")
    ax_metrics.bar(x + width, f1, width, label="F1 score")
    ax_metrics.set_title("Metrik per kelas (data test)")
    ax_metrics.set_ylabel("Skor")
    ax_metrics.set_ylim(0, 1.05)
    ax_metrics.set_xticks(x, ds.class_names)
    ax_metrics.grid(axis="y", alpha=0.25)
    ax_metrics.legend()
    for bars in ax_metrics.containers:
        ax_metrics.bar_label(bars, fmt="%.2f", fontsize=8, padding=2)

    image = ax_cm.imshow(matrix, cmap="Blues")
    ax_cm.set_title("Confusion matrix")
    ax_cm.set_xlabel("Prediksi")
    ax_cm.set_ylabel("Label sebenarnya")
    ax_cm.set_xticks(x, ds.class_names, rotation=30, ha="right")
    ax_cm.set_yticks(x, ds.class_names)
    midpoint = matrix.max() / 2 if matrix.size else 0
    for row in range(matrix.shape[0]):
        for col in range(matrix.shape[1]):
            ax_cm.text(col, row, str(matrix[row, col]), ha="center", va="center",
                       color="white" if matrix[row, col] > midpoint else "black")
    fig.colorbar(image, ax=ax_cm, fraction=0.046, pad=0.04, label="Jumlah gambar")
    plot_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(plot_path, dpi=160, bbox_inches="tight")
    plt.close(fig)
    print(f"Visualisasi tersimpan: {plot_path}")


if __name__ == "__main__":
    main()
