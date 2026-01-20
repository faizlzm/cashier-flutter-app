# Kasir Pro - Flutter POS Application

**Kasir Pro** adalah aplikasi Point of Sale (POS) modern berbasis Flutter untuk bisnis retail dan F&B. Aplikasi ini mendukung operasi offline dengan sinkronisasi otomatis, memungkinkan transaksi tetap berjalan meskipun tidak ada koneksi internet.

## ✨ Fitur Utama

- 🔐 **Autentikasi** - Login, register, dan forgot password
- 🛒 **POS System** - Daftar produk, keranjang belanja, dan checkout
- 📊 **Dashboard** - Ringkasan penjualan, transaksi harian, statistik
- 📝 **Riwayat Transaksi** - Lihat semua transaksi dengan filter tanggal
- 📴 **Offline Support** - SQLite lokal untuk caching produk dan antrian transaksi
- 🔄 **Background Sync** - Sinkronisasi otomatis saat online
- 🌙 **Dark Mode** - Tema gelap dan terang

## 🏗️ Arsitektur

Aplikasi menggunakan arsitektur **Feature-based Clean Architecture**:

```
lib/
├── core/                  # Infrastruktur inti
│   ├── config/            # Konfigurasi aplikasi (API URL)
│   ├── network/           # HTTP client (Dio), API exceptions
│   ├── router/            # GoRouter navigasi
│   ├── services/          # Services (auth, sync, database)
│   ├── theme/             # Tema dan warna aplikasi
│   └── utils/             # Helper dan utilities
├── data/                  # Data layer
│   ├── models/            # Model (Cart, Product, Transaction, User)
│   └── repositories/      # Repository interfaces
├── presentation/          # UI layer
│   ├── layouts/           # Layout (header, sidebar)
│   ├── pages/             # Halaman (auth, dashboard, pos, settings)
│   └── widgets/           # Komponen UI reusable
└── providers/             # Riverpod state providers
```

## 🛠️ Tech Stack

| Kategori             | Library                                                                   |
| -------------------- | ------------------------------------------------------------------------- |
| **State Management** | [Riverpod](https://riverpod.dev/)                                         |
| **Routing**          | [GoRouter](https://pub.dev/packages/go_router)                            |
| **HTTP Client**      | [Dio](https://pub.dev/packages/dio)                                       |
| **Local Database**   | [sqflite](https://pub.dev/packages/sqflite)                               |
| **Secure Storage**   | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| **Icons**            | [Lucide Icons](https://pub.dev/packages/lucide_icons)                     |
| **Fonts**            | [Google Fonts](https://pub.dev/packages/google_fonts)                     |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
- Android Studio / VS Code
- Backend API running (cashier-api)

### Installation

1. **Clone repository**

   ```bash
   git clone <repository-url>
   cd cashier-flutter-app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Konfigurasi API URL**

   Edit file `lib/core/config/app_config.dart` jika perlu mengubah base URL API.

4. **Jalankan aplikasi**

   ```bash
   # Development (debug)
   flutter run

   # Build APK
   flutter build apk

   # Build release APK
   flutter build apk --release
   ```

## 🔧 Development

### Menjalankan Tests

```bash
# Unit tests
flutter test

# Dengan coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Analisis Kode

```bash
# Jalankan dart analyzer
flutter analyze
```

## 📱 Screenshots

> Screenshots akan ditambahkan setelah aplikasi selesai.

## 📄 License

This project is proprietary and confidential.

---

**Kasir Pro** - Solusi Kasir Modern untuk Bisnis Anda 🚀
