# IMPORT LIBRARY DAN KONFIGURASI

import os
import cv2
import joblib
import numpy as np
import pandas as pd

from fastapi import FastAPI, UploadFile, File, HTTPException
from skimage.feature import graycoprops

# MENENTUKAN LOKASI MODEL

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH = os.path.join(BASE_DIR, "random_forest_model.pkl")
FEATURE_PATH = os.path.join(BASE_DIR, "feature_random_forest.pkl")
CLASS_PATH = os.path.join(BASE_DIR, "class_random_forest.pkl")

IMG_SIZE = (224, 224)
KERNEL = np.ones((5, 5), np.uint8)


# Memuat model dan informasi fitur
model = joblib.load(MODEL_PATH)
feature_names = joblib.load(FEATURE_PATH)
class_names = joblib.load(CLASS_PATH)

# Validasi model dan fitur
if len(feature_names) != 16:
    raise ValueError("Jumlah fitur model tidak sesuai!")

if len(class_names) != 4:
    raise ValueError("Jumlah kelas model tidak sesuai!")

if list(model.classes_) != list(class_names):
    raise ValueError("Kelas model tidak sesuai!")

# FUNGSI PREPROCESSING DAN SEGMENTASI

def preprocess_image(image):

    # Resize gambar
    image = cv2.resize(image, IMG_SIZE)

    # Inisialisasi mask GrabCut
    mask = np.zeros(image.shape[:2], np.uint8)

    height, width = image.shape[:2]

    rect = (
        int(width * 0.03),
        int(height * 0.03),
        int(width * 0.94),
        int(height * 0.94)
    )

    background_model = np.zeros((1, 65), np.float64)
    foreground_model = np.zeros((1, 65), np.float64)

    # Segmentasi GrabCut
    cv2.grabCut(
        image,
        mask,
        rect,
        background_model,
        foreground_model,
        5,
        cv2.GC_INIT_WITH_RECT
    )

    # Mengambil area foreground
    mask = np.where(
        (mask == cv2.GC_FGD) |
        (mask == cv2.GC_PR_FGD),
        255,
        0
    ).astype(np.uint8)

    # Morfologi opening dan closing
    mask = cv2.morphologyEx(
        mask,
        cv2.MORPH_OPEN,
        KERNEL
    )

    mask = cv2.morphologyEx(
        mask,
        cv2.MORPH_CLOSE,
        KERNEL
    )

    if cv2.countNonZero(mask) == 0:
        raise ValueError("Objek pisang tidak berhasil disegmentasi.")

    return image, mask

# FUNGSI EKSTRAKSI FITUR WARNA

def extract_color_features(image, mask):

    # Konversi BGR menjadi RGB dan HSV
    rgb = cv2.cvtColor(
        image,
        cv2.COLOR_BGR2RGB
    )

    hsv = cv2.cvtColor(
        image,
        cv2.COLOR_BGR2HSV
    )

    # Mengambil piksel objek pisang
    object_rgb = rgb[mask == 255]
    object_hsv = hsv[mask == 255]

    if len(object_rgb) == 0:
        raise ValueError("Tidak ditemukan piksel objek.")

    features = []

    # Statistik RGB
    for channel in range(3):
        features.append(
            float(np.mean(object_rgb[:, channel]))
        )

        features.append(
            float(np.std(object_rgb[:, channel]))
        )

    # Statistik HSV
    for channel in range(3):
        features.append(
            float(np.mean(object_hsv[:, channel]))
        )

        features.append(
            float(np.std(object_hsv[:, channel]))
        )

    return features

# FUNGSI EKSTRAKSI FITUR TEKSTUR

def extract_texture_features(image, mask):

    # Konversi ke grayscale
    gray = cv2.cvtColor(
        image,
        cv2.COLOR_BGR2GRAY
    )

    # Kuantisasi menjadi 8 tingkat keabuan
    gray_quantized = (gray // 32).astype(np.uint8)

    object_mask = mask == 255

    height, width = gray.shape

    # Matriks GLCM untuk empat arah
    glcm = np.zeros(
        (8, 8, 1, 4),
        dtype=np.float64
    )

    offsets = [
        (0, 1),
        (-1, 1),
        (-1, 0),
        (-1, -1)
    ]

    for i, (dy, dx) in enumerate(offsets):

        y1 = max(0, -dy)
        y2 = min(height, height - dy)

        x1 = max(0, -dx)
        x2 = min(width, width - dx)

        source = gray_quantized[y1:y2, x1:x2]

        target = gray_quantized[
            y1 + dy:y2 + dy,
            x1 + dx:x2 + dx
        ]

        valid = (
            object_mask[y1:y2, x1:x2] &
            object_mask[y1 + dy:y2 + dy,
                        x1 + dx:x2 + dx]
        )

        np.add.at(
            glcm[:, :, 0, i],
            (source[valid], target[valid]),
            1
        )

    # Membuat GLCM simetris
    glcm += glcm.transpose(1, 0, 2, 3)

    # Normalisasi setiap arah
    for i in range(4):

        total = glcm[:, :, 0, i].sum()

        if total > 0:
            glcm[:, :, 0, i] /= total

    # Menghitung empat properti GLCM
    texture_features = []

    for property_name in [
        "contrast",
        "homogeneity",
        "energy",
        "correlation"
    ]:

        values = graycoprops(
            glcm,
            property_name
        )

        texture_features.append(
            float(np.mean(values))
        )

    return texture_features

# MENGGABUNGKAN FITUR WARNA DAN TEKSTUR

def extract_all_features(image):

    # Preprocessing dan segmentasi
    processed_image, mask = preprocess_image(image)

    # Ekstraksi fitur warna
    color_features = extract_color_features(
        processed_image,
        mask
    )

    # Ekstraksi fitur tekstur
    texture_features = extract_texture_features(
        processed_image,
        mask
    )

    # Gabungkan menjadi 16 fitur
    all_features = color_features + texture_features

    if len(all_features) != 16:
        raise ValueError("Jumlah fitur tidak sesuai!")

    return all_features

# FUNGSI PREDIKSI RANDOM FOREST

def predict_banana(image):

    # Ekstraksi 16 fitur
    features = extract_all_features(image)

    # Membuat DataFrame dengan nama fitur model
    input_data = pd.DataFrame(
        [features],
        columns=feature_names
    )

    # Prediksi grade
    prediction = model.predict(input_data)[0]

    # Menghitung probabilitas
    probabilities = model.predict_proba(input_data)[0]

    probability_result = {
        grade: round(float(probability) * 100, 2)
        for grade, probability in zip(
            model.classes_,
            probabilities
        )
    }

    return {
        "predicted_grade": str(prediction),
        "probabilities": probability_result
    }

# MEMBUAT ENDPOINT FASTAPI

app = FastAPI(
    title="API Klasifikasi Grade Pisang",
    description="Klasifikasi grade pisang menggunakan Random Forest",
    version="1.0.0"
)


@app.get("/")
def home():

    return {
        "message": "API Klasifikasi Pisang Berjalan",
        "status": "success"
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):

    # Memeriksa format gambar
    allowed_types = [
        "image/jpeg",
        "image/png"
    ]

    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="File harus berupa JPG atau PNG."
        )

    # Membaca isi gambar
    image_bytes = await file.read()

    if not image_bytes:
        raise HTTPException(
            status_code=400,
            detail="File gambar kosong."
        )

    # Mengubah bytes menjadi gambar OpenCV
    image_array = np.frombuffer(
        image_bytes,
        np.uint8
    )

    image = cv2.imdecode(
        image_array,
        cv2.IMREAD_COLOR
    )

    if image is None:
        raise HTTPException(
            status_code=400,
            detail="Gambar tidak dapat dibaca."
        )

    try:

        # Menjalankan prediksi
        result = predict_banana(image)

        return {
            "status": "success",
            "filename": file.filename,
            "predicted_grade": result["predicted_grade"],
            "probabilities": result["probabilities"]
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Gagal memproses gambar: {str(e)}"
        )


# MENJALANKAN BACKEND

# Server dijalankan melalui terminal:
# uvicorn main:app --host 0.0.0.0 --port 8000 --reload