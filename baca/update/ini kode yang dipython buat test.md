from google.colab import files
from PIL import Image, ImageOps
import numpy as np
import cv2
import matplotlib.pyplot as plt
import tensorflow as tf

TRANSLATE_LABEL = {
    "overripe": "Matang Banget (Overripe)",
    "ripe": "Pisang Matang (Ripe)",
    "rotten": "Pisang Busuk (Rotten)",
    "unripe": "Pisang Mentah (Unripe)"
}

def calibrate_4class_probs(img_uint8, raw_probs, class_names):
    probs = raw_probs.copy()
    h, w, _ = img_uint8.shape
    mh, mw = int(h * 0.12), int(w * 0.12)
    cropped = img_uint8[mh:h-mh, mw:w-mw]
    hsv = cv2.cvtColor(cropped, cv2.COLOR_RGB2HSV)
    r, g, b = cropped[:, :, 0].astype(int), cropped[:, :, 1].astype(int), cropped[:, :, 2].astype(int)

    # Mask piksel aktif (abaikan latar putih/abu-abu)
    active = (hsv[:, :, 1] >= 28) & (hsv[:, :, 2] >= 20) & (hsv[:, :, 0] <= 90)
    total_px = np.sum(active)
    if total_px < 50:
        return probs

    hue, val = hsv[:, :, 0], hsv[:, :, 2]
    green_px  = np.sum(active & (((hue >= 31) & (hue <= 88) & (val >= 40)) | ((g > r + 5) & (g > b + 15))))
    yellow_px = np.sum(active & (hue >= 18) & (hue < 31) & (val >= 110) & (r >= g))
    brown_px  = np.sum(active & ((hue < 18) | (val < 110)))

    green_ratio  = green_px / total_px
    yellow_ratio = yellow_px / total_px
    brown_ratio  = brown_px / total_px

    idx_unripe   = class_names.index('unripe')
    idx_ripe     = class_names.index('ripe')
    idx_overripe = class_names.index('overripe')
    idx_rotten   = class_names.index('rotten')

    # 1. Kalibrasi Pisang Hijau (Unripe) — mengatasi bias meja kayu & kulit mulus
    if green_ratio >= 0.25 and green_ratio > yellow_ratio:
        probs[idx_unripe] = max(probs[idx_unripe], 0.72 + (0.22 * green_ratio))
        probs[idx_ripe]   *= 0.15
        probs[idx_rotten] *= 0.15
        probs /= np.sum(probs)

    # 2. Kalibrasi Pisang Kuning Berbintik Cokelat (Overripe)
    elif green_ratio < 0.20 and yellow_ratio >= 0.18 and (0.15 <= brown_ratio <= 0.68):
        target_overripe = min(0.88, 0.68 + (0.25 * (1.0 - abs(brown_ratio - 0.40))))
        if probs[idx_overripe] < target_overripe:
            donor = probs[idx_rotten] + probs[idx_ripe] + 1e-7
            needed = target_overripe - probs[idx_overripe]
            probs[idx_overripe] += needed
            probs[idx_rotten] = max(0.0, probs[idx_rotten] - needed * (probs[idx_rotten] / donor))
            probs[idx_ripe]   = max(0.0, probs[idx_ripe] - needed * (probs[idx_ripe] / donor))
            probs /= np.sum(probs)

    return probs

print("Silakan upload foto pisang untuk diuji...")
uploaded = files.upload()

for fn in uploaded.keys():
    orig_img = Image.open(fn)
    orig_img = ImageOps.exif_transpose(orig_img).convert("RGB")
    img_resized = orig_img.resize((224, 224), Image.Resampling.BILINEAR)

    img_uint8 = np.array(img_resized, dtype=np.uint8)
    img_batch = np.expand_dims(img_uint8.astype(np.float32), axis=0)

    preprocessed_img = tf.keras.applications.mobilenet_v3.preprocess_input(img_batch.copy())
    cnn_feats = cnn_extractor.predict(preprocessed_img, verbose=0)
    color_feats = extract_color_features_masked(np.expand_dims(img_uint8, axis=0))
    combined_features = np.hstack([cnn_feats, color_feats])

    raw_probs = svm_classifier.predict_proba(combined_features)[0]
    final_probs = calibrate_4class_probs(img_uint8, raw_probs, class_names) * 100

    pred_idx = int(np.argmax(final_probs))
    pred_class = class_names[pred_idx]
    readable_pred = TRANSLATE_LABEL.get(pred_class, pred_class)
    confidence = final_probs[pred_idx]

    plt.figure(figsize=(10, 4))
    plt.subplot(1, 2, 1)
    plt.imshow(orig_img)
    plt.title(f"{readable_pred}\nConfidence: {confidence:.2f}%", fontweight='bold', color='darkgreen')
    plt.axis('off')

    plt.subplot(1, 2, 2)
    labels_id = [TRANSLATE_LABEL.get(c, c) for c in class_names]
    colors = ['#e74c3c' if i != pred_idx else '#2ecc71' for i in range(len(class_names))]
    bars = plt.barh(labels_id, final_probs, color=colors)
    plt.xlim(0, 110)
    plt.xlabel('Confidence (%)')
    plt.title('Distribusi Probabilitas 4 Kelas (Ter-kalibrasi)')
    for bar, prob in zip(bars, final_probs):
        plt.text(bar.get_width() + 1.5, bar.get_y() + bar.get_height()/2, f'{prob:.2f}%', va='center', fontweight='bold')
    plt.tight_layout()
    plt.show()