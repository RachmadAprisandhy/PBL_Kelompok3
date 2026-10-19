# BananaGrade — Flutter UI Prototype

Starter frontend aplikasi Android BananaGrade berdasarkan proposal PBL: deteksi grading visual buah pisang ke Grade A, Grade B, dan Grade C.

## Fitur yang tersedia

- Splash screen dan login/demo masuk.
- Beranda dan navigasi bawah (Beranda, Riwayat, Profil).
- Mengambil foto dari kamera atau memilih gambar dari galeri.
- Halaman hasil grading dengan confidence contoh.
- Penyimpanan riwayat lokal menggunakan SQLite; item dapat dihapus.
- Halaman panduan dan tentang aplikasi.
- Foto yang dipilih disalin ke direktori dokumen aplikasi agar riwayat tidak hanya merujuk ke cache picker.

## Batas prototipe

**Prediksi Grade A dan confidence 92,6% di halaman hasil merupakan data simulasi, bukan hasil CNN.** Model CNN/TensorFlow Lite belum disambungkan. Login juga belum memakai backend/autentikasi. Integrasi model perlu menyesuaikan bentuk input (mis. 224×224), normalisasi, urutan label, dan output dari model TFLite tim.

## Struktur folder

```text
bananagrade_flutter/
├── README.md
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── navigation/
    │   │   └── navigation_cubit.dart
    │   ├── theme/
    │   │   └── app_theme.dart
    │   └── widgets/
    │       └── banana_logo.dart
    ├── data/
    │   ├── local/
    │   │   └── app_database.dart
    │   └── models/
    │       └── grading_result.dart
    └── features/
        ├── auth/
        │   ├── splash_screen.dart
        │   └── login_screen.dart
        ├── home/
        │   ├── app_shell.dart
        │   └── home_screen.dart
        ├── detection/
        │   ├── detection_screen.dart
        │   └── result_screen.dart
        ├── history/
        │   └── history_screen.dart
        ├── profile/
        │   └── profile_screen.dart
        └── info/
            └── info_screens.dart
```

## Cara menjalankan

Pastikan Flutter SDK dan Android Studio/Android SDK sudah terpasang. Periksa instalasi:

```bash
flutter doctor
```

Buat kerangka project terlebih dahulu (di folder tempat project akan disimpan):

```bash
flutter create bananagrade_app
cd bananagrade_app
```

Ekstrak arsip starter di sebelah folder project Flutter. Salin folder `lib` dari `bananagrade_flutter` ke project `bananagrade_app` dan timpa folder `lib` bawaan. Setelah itu jalankan perintah berikut:

```bash
flutter pub add image_picker
flutter pub add sqflite
flutter pub add path
flutter pub add path_provider
flutter pub add intl
flutter pub add flutter_bloc
flutter pub get
flutter run
```

Paket tersebut dipakai untuk kamera/galeri, basis data SQLite, pengelolaan path file, direktori lokal aplikasi, format tanggal riwayat, dan state management BLoC untuk navigasi. Perintah `flutter pub add` akan memilih versi yang kompatibel dengan Flutter/Dart yang terpasang. `sqflite` ditujukan untuk Android/iOS/macOS, bukan Flutter Web.

## Membuat APK debug

Hubungkan perangkat Android dengan USB debugging aktif atau jalankan emulator, lalu:

```bash
flutter devices
flutter run
```

Untuk menghasilkan APK:

```bash
flutter build apk --debug
```

Hasil APK berada di `build/app/outputs/flutter-apk/app-debug.apk`.

## Jika nanti mengintegrasikan CNN/TFLite

Tim perlu menyediakan model `.tflite` dan kontrak preprocessing/output-nya. Sesuaikan label kelas dengan urutan label ketika training. Setelah kompatibilitas model dan perangkat ditentukan, tambahkan paket integrasi yang dibutuhkan, misalnya:

```bash
flutter pub add tflite_flutter
```

Versi `tflite_flutter` dan konfigurasi native perlu dicek terhadap versi Flutter, Android API minimum, dan perangkat target sebelum digunakan. Jangan menganggap confidence softmax sebagai jaminan kebenaran prediksi.
