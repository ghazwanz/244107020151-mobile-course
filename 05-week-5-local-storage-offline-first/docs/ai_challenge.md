# Dokumentasi AI Challenge: Perbandingan Strategi Penyimpanan Lokal

Dokumen ini mencatat prompt, tabel perbandingan, keputusan final, dan hasil verifikasi untuk modul Minggu 05 (Local Storage & Offline-First Architecture).

---

## 1. Prompt yang Digunakan

Prompt resmi yang diajukan ke asisten AI:

> *Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini.*
>
> *Requirements:*
> - *Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing.*
> - *Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel.*
> - *Tunjukkan skema tabel/kotak untuk 1000+ catatan.*
> - *Jelaskan trade-off setiap pilihan.*

---

## 2. Tabel Perbandingan Storage

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| Kompleksitas query | Tidak ada (key-value) | Rendah (box, tanpa query kompleks) | Sedang (SQL manual cukup untuk CRUD + filter) | Rendah (DSL type-safe) |
| Kebutuhan relasi | Tidak mendukung | Tidak mendukung | Mendukung (JOIN, foreign key) | Mendukung (relasi + stream) |
| Reaktivitas (stream) | Tidak | Terbatas (`watch` per box) | Tidak bawaan (perlu invalidate manual) | Ya (watch query reaktif) |
| Type-safety | Rendah (dynamic) | Sedang (butuh adapter) | Rendah (Map mentah) | Tinggi (generated, compile-time) |
| Ukuran boilerplate | Sangat kecil | Kecil | Sedang (SQL + mapping manual) | Besar (codegen, `build_runner`) |
| Kemudahan testing | Mudah | Mudah | Sedang (butuh in-memory / FFI) | Mudah (in-memory bawaan) |

---

## 3. Rekomendasi Final & Alasan

- **Preferensi (tema, waktu terakhir dibuka) → `SharedPreferences`.** Nilainya primitif dan kecil sehingga cukup key-value; tidak perlu skema maupun query.
- **Catatan → `SQLite` via `sqflite`.** Catatan adalah koleksi yang butuh query terurut (`ORDER BY updated_at`), update parsial, dan penanda antrean sync (`dirty`); SQLite mendukung ketiganya dengan boilerplate yang wajar untuk skala codelab.

`Hive` dan `Drift` tidak dipilih: `Hive` lemah untuk query relasional/terurut, sedangkan `Drift` menambah kompleksitas codegen yang belum diperlukan pada kebutuhan CRUD + sync sederhana ini.

---

## 4. Skema untuk 1000+ Catatan

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Indeks agar pengurutan/paginasi 1000+ catatan tetap cepat.
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);

-- Cache data API (cache-first read).
CREATE TABLE cached_posts(
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

Pada skala 1000+ baris, daftar tidak dimuat seluruhnya: gunakan `LIMIT`/`OFFSET` (paginasi) dan andalkan indeks `updated_at` untuk urutan terbaru.

---

## 5. Checklist Verifikasi & Analisis Temuan (*AI Verification Checklist*)

| Kriteria Evaluasi | Status | Catatan Temuan & Analisis |
| :--- | :---: | :--- |
| Daftar catatan tidak ditempatkan di SharedPreferences | ✅ Lolos | Rekomendasi menempatkan catatan di SQLite; SharedPreferences hanya untuk preferensi. |
| Skema mendukung antrean sync (dirty / updated_at) | ✅ Lolos | Tabel `notes` memuat `dirty` dan `updated_at`, cukup untuk antrean sync berbasis penanda. |
| Klaim "real-time" didukung stream | ✅ Lolos | Reaktivitas hanya diklaim untuk Drift (`watch`); untuk sqflite dipakai `ref.invalidate` Riverpod, bukan asumsi. |
| Estimasi boilerplate masuk akal setelah dicoba | ⚠️ Diverifikasi | Setelah `flutter pub add`, sqflite memang ringan (tanpa codegen); Drift butuh `build_runner` seperti diperkirakan. |
| Keputusan final beserta alasan terdokumentasi | ✅ Lolos | Keputusan SharedPreferences + SQLite beserta alasan tercatat pada bagian 3. |

**Perbaikan/keputusan yang diambil sendiri (bukan menerima mentah):** rekomendasi memakai Drift/Hive untuk catatan ditolak karena menambah kompleksitas tanpa manfaat nyata pada skala codelab; klaim reaktivitas tanpa dukungan stream juga ditolak.

---

## 6. Bukti Hasil Pengujian Otomatis

```bash
flutter analyze
# No issues found! (warning unused_import pada settings_page.dart sudah hilang setelah widget SettingsPage ditambahkan)

flutter test
# 00:00 +4: All tests passed!
```
