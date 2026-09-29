# Dokumentasi AI Challenge: Comment Repository Layer

Dokumen ini mencatat proses prompt, evaluasi kode awal, perbaikan teknis (*refinement*), dan hasil verifikasi pengujian otomatis untuk modul Minggu 04 (Networking & REST API Integration) sesuai instruksi Section 6 [materi_praktikum_week4.md](../../materi_praktikum_week4.md).

---

## 1. Prompt yang Digunakan

Prompt resmi yang diajukan ke asisten AI:

> *Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id} dari JSONPlaceholder menggunakan Dio + flutter_riverpod.*
>
> *Requirements:*
> - *Model Comment dengan fromJson aman null (postId, id, name, email, body).*
> - *CommentRepository dengan method fetchComments(postId) + timeout 10 detik.*
> - *AsyncNotifierProvider dengan penanganan error otomatis (AsyncError) dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.*
> - *Satu unit test untuk fromJson dengan field yang hilang.*
>
> *Jelaskan setiap bagian kode dalam komentar.*

---

## 2. Output Awal AI

Output awal yang dihasilkan AI:
- Kelas model `Comment` dengan casting `json['postId'] as int` dan `json['name'] as String`.
- `CommentRepository` yang menginstansiasi instance `Dio()` baru di dalam konstruktor alih-alih menggunakan instance terpusat.
- Provider yang menduplikasi fungsi pemetaan pesan error jaringan secara lokal.
- Unit test sederhana yang hanya memeriksa `postId` tanpa menguji nilai *fallback default* dari string kosong.

---

## 3. Checklist Verifikasi & Analisis Temuan (*AI Verification Checklist*)

| Kriteria Evaluasi | Status | Catatan Temuan & Analisis |
| :--- | :---: | :--- |
| **Pemisahan Lapisan (UI tidak memanggil Dio)** | ✅ Lolos | Seluruh pemanggilan HTTP dibungkus dalam `CommentRepository`. UI hanya membaca provider Riverpod. |
| **Serialisasi Null-Safe Defensif** | ⚠️ Diperbaiki | Model awal menggunakan cast langsung `as int` dan `as String`. Jika API mengembalikan nilai `null` atau field hilang, akan terjadi runtime crash `TypeError: null is not a subtype of type 'String'`. |
| **Klien HTTP Terpusat** | ⚠️ Diperbaiki | Kode awal membuat instance `Dio()` baru per repository. Hal ini memboroskan resource dan mengabaikan interceptor serta konfigurasi base URL terpusat dari `api_client.dart`. |
| **Pemetaan Error Jaringan** | ✅ Lolos | Memanfaatkan fungsi `friendlyErrorMessage` yang telah memetakan `DioExceptionType` (timeout, connection error, bad response 400/401/403/404/500). |
| **Cakupan Pengujian Edge Case** | ⚠️ Diperbaiki | Unit test awal hanya menguji *happy path*. Perlu ditambahkan edge case ketika field bernilai `null` secara eksplisit dan verifikasi bahwa string kosong (`''`) dihasilkan tanpa melempar exception. |
| **flutter analyze & flutter test** | ✅ Lolos | Seluruh kode lolos analisis statis tanpa warning (0 issues) dan tes lulus 100%. |

---

## 4. Perbaikan Teknis yang Dilakukan

1. **Casting Defensif pada Model `Comment`**:
   - Mengubah `json['postId'] as int` menjadi `(json['postId'] as num?)?.toInt() ?? 0`.
   - Mengubah `json['name'] as String` menjadi `json['name'] as String? ?? ''`.
   - Pola ini memastikan aplikasi tidak crash saat terjadi perubahan kontrak skema data backend.
2. **Injeksi Dependensi Dio Terpusat**:
   - Mengarahkan `CommentRepository` untuk menerima `Dio` dari `dioProvider` (`createDio()`), sehingga mewarisi base URL, connect/receive timeout 10 detik, dan `LogInterceptor`.
3. **Penyediaan Provider yang Fleksibel**:
   - Menyediakan `CommentsNotifier` (`AsyncNotifier<List<Comment>>`) dan `commentsFamilyProvider` (`FutureProvider.family<List<Comment>, int>`) agar mudah dikonsumsi pada halaman detail post berdasarkan `postId`.
4. **Penambahan Edge Case Unit Testing**:
   - Menambahkan pengujian `test/comment_test.dart` yang menguji kasus nilai `null` pada atribut serta verifikasi keselarasan metode `toJson()`.

---

## 5. Bukti Hasil Pengujian Otomatis

Pengujian unit pada `test/comment_test.dart` dieksekusi dengan hasil:

```bash
flutter test test/comment_test.dart
00:00 +0: Comment Model Serialization Tests fromJson aman terhadap field yang hilang (missing fields)
00:00 +1: Comment Model Serialization Tests fromJson menangani nilai null dan tipe tidak sesuai secara defensif (edge case)
00:00 +2: Comment Model Serialization Tests toJson menghasilkan Map yang konsisten dengan objek model
00:00 +3: All tests passed!
```
