# Panduan Cloudflare Tunnel untuk Cashier App

## Overview

Cloudflare Tunnel digunakan untuk mengekspos backend API lokal ke internet dengan HTTPS, memungkinkan Flutter mobile app terhubung ke backend melalui URL publik yang aman.

## Tunnel URL

```
https://cashier-api.faizlzm.com
```

---

## Konfigurasi Flutter App

File: `lib/core/config/app_config.dart`

### Mengaktifkan Mode Tunnel

```dart
// Set true untuk menggunakan Cloudflare Tunnel
static const bool useTunnel = true;

// URL tunnel Anda
static const String tunnelUrl = 'https://cashier-api.faizlzm.com';
```

### Kembali ke Local Development

```dart
// Set false untuk development lokal
static const bool useTunnel = false;
```

---

## Menjalankan Cloudflare Tunnel

### Cek Status Service

Buka Command Prompt sebagai Administrator:

```cmd
sc query cloudflared
```

### Start Service (jika tidak running)

```cmd
net start cloudflared
```

### Stop Service

```cmd
net stop cloudflared
```

---

## Verifikasi

1. **Pastikan backend berjalan**:

   ```bash
   cd cashier-api
   npm run dev
   ```

2. **Cek tunnel di browser**:
   Buka `https://cashier-api.faizlzm.com/api/products`

3. **Test dari Flutter app**:
   - Pastikan `useTunnel = true` di `app_config.dart`
   - Jalankan Flutter app
   - Login dengan `admin@kasirpro.com` / `admin123`

---

## Troubleshooting

| Masalah                      | Solusi                                                        |
| ---------------------------- | ------------------------------------------------------------- |
| Tunnel INACTIVE di dashboard | Jalankan `net start cloudflared` sebagai Admin                |
| Connection refused           | Pastikan `npm run dev` berjalan di cashier-api                |
| CORS error                   | Cek `.env` sudah include tunnel URL di `CORS_ORIGIN`          |
| Timeout                      | Cek cloudflared service running dengan `sc query cloudflared` |
