"""Train and evaluate a compact CNN from folder-based image splits."""
from pathlib import Path
import argparse
import tensorflow as tf

DATA_DIR = Path(__file__).resolve().parent.parent / "dataset" / "prepared"
MODEL_DIR = Path(__file__).resolve().parent.parent / "models"
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16
EPOCHS = 25
SEED = 42


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", type=Path, default=DATA_DIR)
    parser.add_argument("--model-path", type=Path, default=MODEL_DIR / "banana_cnn.keras")
    args = parser.parse_args()
    tf.keras.utils.set_random_seed(SEED)
    data_dir = args.data_dir.resolve()
    best_path = args.model_path.resolve()
    paths = {name: data_dir / name for name in ("train", "validation", "test")}
    for name, path in paths.items():
        if not path.is_dir():
            raise FileNotFoundError(f"Missing {name} split: {path}. Run src/split_dataset.py first.")

    train_ds = tf.keras.utils.image_dataset_from_directory(
        paths["train"], image_size=IMAGE_SIZE, batch_size=BATCH_SIZE, seed=SEED)
    class_names = train_ds.class_names
    val_ds = tf.keras.utils.image_dataset_from_directory(
        paths["validation"], class_names=class_names, image_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE, shuffle=False)
    test_ds = tf.keras.utils.image_dataset_from_directory(
        paths["test"], class_names=class_names, image_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE, shuffle=False)
    autotune = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(autotune)
    val_ds = val_ds.prefetch(autotune)
    test_ds = test_ds.prefetch(autotune)

    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(*IMAGE_SIZE, 3)),
        tf.keras.layers.Rescaling(1.0 / 255),
        tf.keras.layers.RandomFlip("horizontal"),
        tf.keras.layers.RandomRotation(0.08),
        tf.keras.layers.Conv2D(32, 3, padding="same", activation="relu"),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Conv2D(64, 3, padding="same", activation="relu"),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Conv2D(128, 3, padding="same", activation="relu"),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.GlobalAveragePooling2D(),
        tf.keras.layers.Dense(128, activation="relu"),
        tf.keras.layers.Dropout(0.35),
        tf.keras.layers.Dense(len(class_names), activation="softmax"),
    ])
    model.compile(optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    best_path.parent.mkdir(parents=True, exist_ok=True)
    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(best_path, monitor="val_loss", save_best_only=True, verbose=1),
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=5, restore_best_weights=True),
    ]
    model.fit(train_ds, validation_data=val_ds, epochs=EPOCHS, callbacks=callbacks)
    best = tf.keras.models.load_model(best_path)
    loss, accuracy = best.evaluate(test_ds, verbose=1)
    # Compute multiclass precision, recall, and F1 from the test confusion matrix.
    y_true = tf.concat([labels for _, labels in test_ds], axis=0)
    probabilities = best.predict(test_ds, verbose=0)
    y_pred = tf.argmax(probabilities, axis=1, output_type=y_true.dtype)
    matrix = tf.math.confusion_matrix(y_true, y_pred, num_classes=len(class_names)).numpy()
    tp = matrix.diagonal().astype("float64")
    precision_by_class = tp / (matrix.sum(axis=0) + 1e-12)
    recall_by_class = tp / (matrix.sum(axis=1) + 1e-12)
    f1_by_class = 2 * precision_by_class * recall_by_class / (precision_by_class + recall_by_class + 1e-12)
    print(f"Classes: {class_names}")
    print(f"Test loss: {loss:.4f}; test accuracy: {accuracy:.4f}")
    for i, name in enumerate(class_names):
        print(f"{name}: precision={precision_by_class[i]:.4f}, recall={recall_by_class[i]:.4f}, f1={f1_by_class[i]:.4f}")
    print(f"Macro average: precision={precision_by_class.mean():.4f}, recall={recall_by_class.mean():.4f}, f1={f1_by_class.mean():.4f}")


if __name__ == "__main__":
    main()
