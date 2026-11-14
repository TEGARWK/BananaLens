Berikut adalah panduan lengkap langkah demi langkah untuk **Cara 1 (Integrasi via Backend Python FastAPI di Laptop + Flutter di HP)**. Dengan cara ini, aplikasi Flutter di HP kamu akan mengirim foto pisang ke laptop melalui Wi-Fi/Hotspot, lalu laptop memprosesnya dengan **MobileNetV3 + `svm_pisang_hybrid.pkl**` dan mengembalikan hasilnya dalam hitungan milidetik.

---

## Tahap 1: Persiapan Backend Server Python di Laptop

1. **Buat Folder Khusus Backend:**
Buat sebuah folder baru di laptop kamu, misalnya di `C:\banana_backend` atau `D:\banana_backend`.
2. **Pindahkan File `.pkl`:**
Masukkan file **`svm_pisang_hybrid.pkl`** (yang sudah kamu download dari Sel 8 Google Colab) ke dalam folder `banana_backend` tersebut.
3. **Buat File `main.py`:**
Buka folder `banana_backend` menggunakan **VS Code**, lalu buat file baru bernama **`main.py`** sehingga struktur foldernya seperti ini:
```text
banana_backend/
├── svm_pisang_hybrid.pkl
└── main.py

```


4. **Isi Kode `main.py`:**
Salin dan simpan kode berikut ke dalam `main.py`:

```python
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
import cv2
import joblib
from PIL import Image, ImageOps
import io

app = FastAPI(title="API Deteksi Pisang 3 Kelas (Hybrid CNN + HSV + PCA + SVM)")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. Load MobileNetV3Small (576 Fitur)
cnn_extractor = tf.keras.applications.MobileNetV3Small(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet',
    pooling='avg'
)
cnn_extractor.trainable = False

# 2. Load Pipeline (StandardScaler + PCA 60 + SVM) dari file .pkl
model_bundle = joblib.load('svm_pisang_3kelas.pkl')
svm_model = model_bundle['svm_model']
class_names = model_bundle['class_names'] # ['ripe', 'rotten', 'unripe']

TRANSLATE_LABEL = {
    "ripe": "Pisang Matang (Ripe)",
    "rotten": "Pisang Busuk (Rotten)",
    "unripe": "Pisang Mentah (Unripe)"
}

# 3. Fungsi Ekstraksi 30 Fitur Warna HSV
def extract_single_color_feature(img_uint8):
    hsv = cv2.cvtColor(img_uint8, cv2.COLOR_RGB2HSV)
    h_hist = cv2.calcHist([hsv], [0], None, [12], [0, 180]).flatten()
    s_hist = cv2.calcHist([hsv], [1], None, [6], [0, 256]).flatten()
    v_hist = cv2.calcHist([hsv], [2], None, [6], [0, 256]).flatten()
    
    h_hist /= (h_hist.sum() + 1e-7)
    s_hist /= (s_hist.sum() + 1e-7)
    v_hist /= (v_hist.sum() + 1e-7)
    
    mean_hsv = np.mean(hsv, axis=(0, 1)) / 255.0
    std_hsv  = np.std(hsv, axis=(0, 1)) / 255.0
    
    return np.concatenate([h_hist, s_hist, v_hist, mean_hsv, std_hsv]).reshape(1, -1)

@app.get("/")
def home():
    return {
        "status": "Server Aktif",
        "pipeline": "MobileNetV3 (576) + HSV (30) -> StandardScaler -> PCA (60) -> SVM (3 Kelas)",
        "classes": class_names
    }

@app.post("/predict")
async def predict_banana(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))
        
        # Koreksi rotasi kamera HP & ubah ke 224x224 RGB
        image = ImageOps.exif_transpose(image).convert("RGB")
        image = image.resize((224, 224), Image.Resampling.BILINEAR)
        
        img_uint8 = np.array(image, dtype=np.uint8)
        img_float = img_uint8.astype(np.float32)
        img_batch = np.expand_dims(img_float, axis=0)
        
        # A. Ekstraksi 576 fitur MobileNetV3
        preprocessed_img = tf.keras.applications.mobilenet_v3.preprocess_input(img_batch)
        cnn_feats = cnn_extractor.predict(preprocessed_img, verbose=0)
        
        # B. Ekstraksi 30 fitur warna HSV
        color_feats = extract_single_color_feature(img_uint8)
        
        # C. Gabungkan menjadi 606 fitur (Nanti otomatis dipadatkan jadi 60 fitur oleh PCA di dalam .pkl)
        combined_features = np.hstack([cnn_feats, color_feats])
        
        # D. Prediksi via Pipeline SVM
        pred_idx = int(svm_model.predict(combined_features)[0])
        probabilities = svm_model.predict_proba(combined_features)[0] * 100
        
        raw_class = class_names[pred_idx]
        readable_label = TRANSLATE_LABEL.get(raw_class, raw_class)
        confidence = float(probabilities[pred_idx])
        
        prob_details = {
            TRANSLATE_LABEL.get(class_names[i], class_names[i]): round(float(probabilities[i]), 2)
            for i in range(len(class_names))
        }
        
        return {
            "status": "success",
            "prediction": readable_label,
            "raw_class": raw_class,
            "confidence": round(confidence, 2),
            "details": prob_details
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}
```

5. **Install Library & Jalankan Server:**
Buka Terminal di VS Code (`Ctrl + ~`), pastikan berada di dalam direktori `banana_backend`, lalu jalankan perintah instalasi ini (cukup sekali saja):
```bash
pip install fastapi uvicorn tensorflow scikit-learn joblib pillow python-multipart

```


Setelah terinstal, nyalakan server dengan perintah:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000

```


*Tunggu sampai muncul tulisan `Uvicorn running on [http://0.0.0.0:8000](http://0.0.0.0:8000)`. Saat pertama kali dijalankan, TensorFlow akan mengunduh bobot MobileNetV3Small (~4 MB) secara otomatis.*

---

## Tahap 2: Mengetahui IP Address Laptop & Setting Jaringan

Agar HP kamu bisa mengirim gambar ke laptop:

1. **Pastikan HP dan Laptop berada di jaringan yang sama.** (Tips paling stabil: Nyalakan **Hotspot** di HP kamu, lalu sambungkan Wi-Fi laptop ke Hotspot HP tersebut).
2. Buka **Command Prompt (CMD)** di Windows laptopmu, ketik:
```cmd
ipconfig

```


3. Cari bagian **Wireless LAN adapter Wi-Fi** dan lihat angka di baris **IPv4 Address** (contoh: `192.168.43.105` atau `192.168.1.12`). Catat angka tersebut.
4. **Cek di Browser HP:** Buka Chrome di HP kamu, ketik `http://IP_LAPTOP_KAMU:8000` (misal `[http://192.168.43.105:8000](http://192.168.43.105:8000)`).
* Jika muncul teks JSON `{"status": "Server Aktif", ...}`, berarti koneksi HP ke laptop sudah berhasil!
* *Jika tidak bisa dibuka:* Matikan sementara *Windows Defender Firewall* untuk jaringan publik/privat di laptop karena kadang memblokir port `8000`.



---

## Tahap 3: Konfigurasi Project Flutter di HP

1. **Buat Project Flutter Baru (atau gunakan yang sudah ada):**
```bash
flutter create deteksi_pisang_app
cd deteksi_pisang_app

```


2. **Tambahkan Package `http` dan `image_picker`:**
Jalankan di terminal project Flutter:
```bash
flutter pub add http image_picker

```


3. **Izinkan Koneksi HTTP & Kamera di Android (`AndroidManifest.xml`):**
Buka file `android/app/src/main/AndroidManifest.xml`. Karena server lokal kita menggunakan `http://` (bukan `https://`), Android secara default memblokirnya kecuali kita menambahkan izin internet dan `android:usesCleartextTraffic="true"`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- TAMBAHKAN IZIN INTERNET DI SINI -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="Deteksi Pisang"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true"> <!-- WAJIB TAMBAHKAN BARIS INI -->

        <activity ...>

```


4. **Kode Lengkap Aplikasi Flutter (`lib/main.dart`):**
Buka file `lib/main.dart`, hapus semua isinya, dan ganti dengan kode di bawah ini (jangan lupa sesuaikan variabel `serverIp` dengan IPv4 laptopmu):

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BananaRipenessApp());
}

class BananaRipenessApp extends StatelessWidget {
  const BananaRipenessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deteksi Pisang Hybrid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const DetectionScreen(),
    );
  }
}

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  // GANTI IP INI DENGAN IPv4 LAPTOP KAMU DARI CMD (ipconfig)
  final TextEditingController _ipController = TextEditingController(text: "192.168.1.12:8000");

  File? _imageFile;
  bool _isLoading = false;
  String? _prediction;
  double? _confidence;
  Map<String, dynamic>? _probDetails;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndPredict(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _isLoading = true;
      _errorMessage = null;
      _prediction = null;
    });

    final String apiUrl = "http://${_ipController.text.trim()}/predict";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _prediction = data['prediction'];
            _confidence = (data['confidence'] as num).toDouble();
            _probDetails = data['details'];
          });
        } else {
          setState(() => _errorMessage = data['message']);
        }
      } else {
        setState(() => _errorMessage = "Server merespons dengan status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal terhubung ke $apiUrl.\nPastikan server Python menyala serta HP dan Laptop berada di jaringan Wi-Fi/Hotspot yang sama.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deteksi Kematangan Pisang"),
        backgroundColor: Colors.amber.shade400,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kolom input IP Server agar mudah diganti langsung dari layar HP tanpa build ulang
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "Alamat IP Server Laptop (IP:Port)",
                prefixText: "http://",
                suffixText: "/predict",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),

            // Kotak Pratinjau Gambar
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _imageFile == null
                  ? const Center(
                      child: Text(
                        "Belum ada foto pisang.\nSilakan ambil dari Kamera atau Galeri.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(height: 16),

            // Tombol Kamera & Galeri
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickAndPredict(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Kamera"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickAndPredict(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galeri"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Indikator Loading
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Mengekstrak fitur MobileNetV3 & Klasifikasi SVM..."),
                  ],
                ),
              ),

            // Pesan Error
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              ),

            // Kartu Hasil Prediksi
            if (_prediction != null && !_isLoading)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hasil Klasifikasi Hybrid:", style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(
                        _prediction!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        "Tingkat Keyakinan (Confidence): $_confidence%",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 24),
                      const Text("Rincian Probabilitas 4 Kelas SVM:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_probDetails != null)
                        ..._probDetails!.entries.map((entry) {
                          final double val = (entry.value as num).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text("$val%", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: val / 100.0,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

```

### Kelebihan Desain Kode Flutter Di Atas:

* **Kotak Input IP Langsung di Layar:** Saya menambahkan kotak input IP (`TextField`) di bagian atas aplikasi. Jadi kalau kamu pindah tempat atau IP Wi-Fi laptopmu berubah saat presentasi di kelas, kamu **tidak perlu *build* ulang kodingan Flutter**—cukup ketik IP baru langsung di layar HP!
* **Visualisasi Progress Bar 4 Kelas:** Selain menampilkan hasil pemenang, aplikasi juga menampilkan grafik bar persentase untuk keempat kelas (`Overripe`, `Ripe`, `Rotten`, `Unripe`) secara lengkap.

Silakan coba jalankan dulu training di Google Colab sampai file `svm_pisang_hybrid.pkl` terunduh, lalu kita tes server `main.py` ini. Jika ada kendala di salah satu langkahnya, langsung beritahu saya!