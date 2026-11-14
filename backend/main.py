import io
import os
from typing import Any

import cv2
import joblib
import numpy as np
import tensorflow as tf
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image, ImageOps

CANDIDATE_MODEL_NAMES = [
    "svm_pisang_3kelasNew.pkl",
    "svm_pisang_3kelas.pkl",
    "svm_pisang_3kelas(96%).pkl",
    "svm_pisang_hybrid.pkl",
]

TRANSLATE_LABEL: dict[str, str] = {
    "unripe": "Mentah",
    "ripe": "Matang",
    "overripe": "Terlalu Matang",
    "rotten": "Busuk",
}

app = FastAPI(
    title="API Deteksi Kematangan Pisang (Hybrid MobileNetV3 + HSV + PCA + SVM)"
)

# Mengizinkan akses dari aplikasi mobile Flutter / Web / Emulator
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _load_model_bundle() -> tuple[dict[str, Any], str]:
    """Load the serialized SVM pipeline bundle from baca/ or backend/."""
    base_dir = os.path.dirname(__file__)
    for filename in CANDIDATE_MODEL_NAMES:
        candidate_paths = [
            os.path.join(base_dir, "..", "baca", filename),
            os.path.join(base_dir, filename),
            filename,
        ]
        for path in candidate_paths:
            if os.path.exists(path):
                print(f"2. Memuat model Pipeline SVM dari: {path}")
                return joblib.load(path), os.path.abspath(path)
    raise FileNotFoundError(
        f"Tidak ada model SVM yang ditemukan dari daftar {CANDIDATE_MODEL_NAMES}!"
    )


# 1. Load MobileNetV3Small (Output: 576 fitur)
print("1. Memuat MobileNetV3Small sebagai Feature Extractor (224x224x3)...")
cnn_extractor = tf.keras.applications.MobileNetV3Small(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
    pooling="avg",
)
cnn_extractor.trainable = False

# 2. Load Model Pipeline SVM (.pkl)
model_bundle, loaded_model_path = _load_model_bundle()
MODEL_FILENAME = os.path.basename(loaded_model_path)
svm_model = model_bundle["svm_model"]
class_names: list[str] = [str(c) for c in model_bundle["class_names"]]
HSV_WEIGHT: float = float(model_bundle.get("hsv_weight", 2.5))
print(f"Model SVM aktif ({len(class_names)} kelas): {class_names}")
print(f"Bobot pengali HSV (hsv_weight): {HSV_WEIGHT}")


# 3. Fungsi Ekstraksi 30 Fitur Warna HSV dengan Background Masking (Identik dengan Colab)
def extract_single_color_feature_masked(
    img_uint8: np.ndarray, hsv_weight: float = 2.5
) -> np.ndarray:
    """Center crop 12%, mask banana spectrum (Hue 0-85), compute 30 HSV features."""
    # A. Center Crop (Potong 12% tepi luar untuk membuang background meja/lantai/terpal)
    h, w, _ = img_uint8.shape
    mh, mw = int(h * 0.12), int(w * 0.12)
    cropped = img_uint8[mh : h - mh, mw : w - mw]

    hsv = cv2.cvtColor(cropped, cv2.COLOR_RGB2HSV)

    # B. Masking: Fokus pada spektrum warna pisang (cokelat/kuning/hijau: Hue 0-85)
    # Abaikan latar putih/abu-abu (Saturation < 28) dan terpal biru/ungu (Hue > 85)
    lower_banana = np.array([0, 28, 20])
    upper_banana = np.array([85, 255, 255])
    mask = cv2.inRange(hsv, lower_banana, upper_banana)

    if cv2.countNonZero(mask) < 50:
        mask = None

    # C. Hitung Histogram Hue (12 bin: 0-90), Saturation (6 bin), Value (6 bin)
    h_hist = cv2.calcHist([hsv], [0], mask, [12], [0, 90]).flatten()
    s_hist = cv2.calcHist([hsv], [1], mask, [6], [0, 256]).flatten()
    v_hist = cv2.calcHist([hsv], [2], mask, [6], [0, 256]).flatten()

    h_hist /= h_hist.sum() + 1e-7
    s_hist /= s_hist.sum() + 1e-7
    v_hist /= v_hist.sum() + 1e-7

    # D. Hitung Mean & Std Deviasi HSV pada area mask pisang
    if mask is not None:
        mean_val, std_val = cv2.meanStdDev(hsv, mask=mask)
        mean_hsv = mean_val.flatten() / 255.0
        std_hsv = std_val.flatten() / 255.0
    else:
        mean_hsv = np.mean(hsv, axis=(0, 1)) / 255.0
        std_hsv = np.std(hsv, axis=(0, 1)) / 255.0

    feat = np.concatenate([h_hist, s_hist, v_hist, mean_hsv, std_hsv]) * hsv_weight
    return feat.astype(np.float32).reshape(1, -1)


# Alias backward compatibility
extract_color_features = extract_single_color_feature_masked


def prepare_image_arrays(image_bytes: bytes) -> tuple[np.ndarray, np.ndarray]:
    """Apply EXIF orientation fix and resize RGB image to 224x224 arrays."""
    with Image.open(io.BytesIO(image_bytes)) as raw_image:
        oriented = ImageOps.exif_transpose(raw_image).convert("RGB")
        resized = oriented.resize((224, 224), Image.Resampling.BILINEAR)
        img_uint8 = np.array(resized, dtype=np.uint8)

    img_batch = np.expand_dims(img_uint8.astype(np.float32), axis=0)
    return img_uint8, img_batch


def build_hybrid_features(image_bytes: bytes) -> np.ndarray:
    """Combine 576 MobileNetV3 features and 30 masked HSV features into 606-dim vector."""
    img_uint8, img_batch = prepare_image_arrays(image_bytes)
    preprocessed = tf.keras.applications.mobilenet_v3.preprocess_input(
        img_batch.copy()
    )
    cnn_feats = cnn_extractor.predict(preprocessed, verbose=0)
    color_feats = extract_single_color_feature_masked(
        img_uint8, hsv_weight=HSV_WEIGHT
    )
    return np.hstack([cnn_feats, color_feats])


@app.get("/")
def home() -> dict[str, Any]:
    """Return active backend status and pipeline metadata."""
    return {
        "status": "Server Aktif",
        "service": "FruitLens AI Backend",
        "model_file": MODEL_FILENAME,
        "split_ratio": "80% Train : 20% Test",
        "architecture": "MobileNetV3 (576 -> PCA 100) + Masked HSV (30) -> SVM (130 Fitur Input)",
        "hsv_weight": HSV_WEIGHT,
        "classes": class_names,
    }


# Alias for backward-compatible health check
health_check = home


@app.post("/predict")
async def predict_banana(file: UploadFile = File(...)) -> dict[str, Any]:
    """Predict banana ripeness with MobileNetV3 + Masked HSV + PCA + SVM pipeline."""
    try:
        # 1. Baca byte gambar & perbaiki orientasi EXIF kamera HP
        image_bytes = await file.read()
        combined_features = build_hybrid_features(image_bytes)

        # 2. Prediksi Kelas & Probabilitas via Pipeline SVM
        pred_idx = int(svm_model.predict(combined_features)[0])
        probabilities = svm_model.predict_proba(combined_features)[0] * 100.0

        raw_class = class_names[pred_idx]
        readable_label = TRANSLATE_LABEL.get(raw_class, raw_class)
        confidence = float(probabilities[pred_idx])

        # Rincian probabilitas untuk ketiga kelas
        prob_details = {
            class_names[i]: round(float(probabilities[i]), 2)
            for i in range(len(class_names))
        }

        print(
            f"[PREDIKSI] Hasil: {readable_label} ({raw_class}) | "
            f"Confidence: {confidence:.2f}% | Detail: {prob_details}"
        )

        return {
            "status": "success",
            "fruit": "Pisang",
            "fruit_label": "banana",
            "prediction": readable_label,
            "raw_class": raw_class,
            "confidence": round(confidence, 2),
            "details": prob_details,
        }
    except Exception as exc:
        return {"status": "error", "message": str(exc)}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
