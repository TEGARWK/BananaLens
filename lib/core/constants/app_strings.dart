/// Centralized UI text in Indonesian (see AGENTS.md section 4).
abstract final class AppStrings {
  static const String appName = 'FruitLens';

  // Navigation tabs
  static const String navHome = 'Beranda';
  static const String navChat = 'Tanya AI';
  static const String navScan = 'Pindai';
  static const String navHistory = 'Riwayat';
  static const String navProfile = 'Profil';

  // Placeholder screen titles & descriptions
  static const String homeTitle = 'Beranda FruitLens';
  static const String homeSubtitle =
      'Pantau kematangan buah, kandungan nutrisi, dan inspirasi olahan sehat harian.';

  static const String scanTitle = 'Pemindai Buah';
  static const String scanSubtitle =
      'Arahkan kamera ke buah untuk mendeteksi jenis dan tingkat kematangannya.';

  static const String chatTitle = 'Asisten AI FruitLens';
  static const String chatSubtitle =
      'Tanyakan informasi gizi, resep, atau cara penyimpanan buah segar.';

  static const String historyTitle = 'Riwayat Pindai';
  static const String historySubtitle =
      'Daftar buah yang telah Anda pindai tersimpan secara lokal di perangkat.';

  static const String profileTitle = 'Profil Pengguna';
  static const String profileSubtitle =
      'Kelola preferensi nutrisi, target kesehatan, dan riwayat alergi.';

  // Camera & permission
  static const String cameraPermissionTitle = 'Izin kamera dibutuhkan';
  static const String cameraPermissionBody =
      'FruitLens memakai kamera untuk mengenali buah. Fotomu diproses di '
      'perangkat dan tidak dikirim ke mana pun.';
  static const String cameraAllow = 'Izinkan kamera';
  static const String cameraOpenSettings = 'Buka pengaturan';
  static const String cameraPermanentlyDeniedBody =
      'Izin kamera dimatikan. Aktifkan lewat pengaturan aplikasi untuk mulai '
      'memindai, atau pilih foto dari galeri.';
  static const String cameraUnavailableTitle = 'Kamera tidak tersedia';
  static const String cameraUnavailableBody =
      'Kamera tidak bisa dibuka. Coba lagi, atau pilih foto dari galeri.';
  static const String cameraRetry = 'Coba lagi';
  static const String cameraGuide = 'Letakkan satu buah di dalam bingkai';
  static const String shutterLabel = 'Ambil foto';
  static const String galleryLabel = 'Pilih dari galeri';
  static const String pickFromGallery = 'Pilih dari galeri';

  // Scan result
  static const String resultTitle = 'Hasil Pindai';
  static const String resultAnalyzing = 'Menganalisis buah…';
  static const String resultAnalyzingHint =
      'Mengenali jenis dan tingkat kematangan.';
  static const String resultUncertainTitle = 'Buah tidak dikenali';
  static const String resultUncertainBody =
      'Coba foto ulang dengan cahaya cukup, satu buah saja, dan jarak lebih '
      'dekat.';
  static const String resultErrorTitle = 'Pemindaian gagal';
  static const String resultErrorBody =
      'Terjadi masalah saat memproses foto. Coba lagi.';
  static const String resultRetake = 'Foto ulang';
  static const String resultRetry = 'Coba lagi';
  static const String resultConfidenceFruit = 'Keyakinan jenis';
  static const String resultConfidenceRipeness = 'Keyakinan kematangan';
  static const String resultNutritionTitle = 'Gizi per 100 g';
  static const String resultCalories = 'Kalori';
  static const String resultCarbs = 'Karbohidrat';
  static const String resultSugar = 'Gula';
  static const String resultFiber = 'Serat';
  static const String resultUnitKcal = 'kkal';
  static const String resultUnitGram = 'g';
  static const String resultVitamins = 'Vitamin utama';
  static const String resultBenefits = 'Manfaat';
  static const String resultStorage = 'Cara menyimpan';
  static const String resultAllergen = 'Catatan alergi';
  static const String resultNoNutrition =
      'Data gizi untuk buah ini belum tersedia.';
  static const String resultPhotoSemantics = 'Foto buah yang dipindai';

  // Ripeness
  static const String ripenessUnripe = 'Mentah';
  static const String ripenessRipe = 'Matang';
  static const String ripenessOverripe = 'Terlalu matang';
  static const String ripenessRotten = 'Busuk';

  // Server & AI Hybrid Configuration
  static const String serverConfigTitle = 'Pengaturan Server AI';
  static const String serverAddressLabel = 'Alamat Server AI (IP:Port)';
  static const String serverAddressHint = '10.0.2.2:8000';
  static const String serverTestConnection = 'Tes Koneksi';
  static const String serverTesting = 'Memeriksa server…';
  static const String serverConnected = 'Server Aktif & Terhubung';
  static const String serverDisconnected = 'Gagal Terhubung ke Server';
  static const String serverSave = 'Simpan Pengaturan';
  static const String serverUseFallback =
      'Gunakan Model Lokal / Demo jika Server Offline';
  static const String serverBreakdownTitle = 'Rincian Probabilitas 4 Kelas SVM';

  // Rotten Fruit Safety & Guidance
  static const String rottenAdviceTitle = 'PERINGATAN KEAMANAN PANGAN';
  static const String rottenAdviceWarning =
      'Buah menunjukkan tanda pembusukan atau penurunan kualitas secara signifikan. Sebaiknya tidak dikonsumsi demi kesehatan pencernaan.';
  static const String rottenEcoTitle = 'SARAN PENANGANAN';
  static const String rottenEcoBody =
      'Manfaatkan sebagai kompos organik atau bahan fermentasi eco-enzyme agar tidak terbuang sia-sia.';
  static const String rottenRecycleButton = 'Tips Daur Ulang';
  static const String rottenSheetTitle = 'Buah Tidak Layak Konsumsi';
  static const String rottenSheetStepsTitle =
      'Saran Pengolahan & Penanganan Ramah Lingkungan:';
  static const String rottenSheetStepsBody =
      '1. Kompos Organik: Potong kecil-kecil dan jadikan bahan kompos pupuk alami tanaman Anda.\n'
      '2. Eco-Enzyme: Fermentasikan bersama gula merah dan air untuk cairan pembersih serbaguna.\n'
      '3. Jangan Dikonsumsi: Menghindari risiko infeksi bakteri atau toksin jamur pada saluran pencernaan.';
  static const String rottenSheetAcknowledge = 'Mengerti';

  // Splash Screen
  static const String splashBadge = 'PEMINDAI KEMATANGAN AI';
  static const String splashTagline = 'Kenali Segarnya Setiap Buah';
  static const String splashSemantics = 'Logo FruitLens';
}
