# Refleksi Pembelajaran: Minggu 05

- **Topik**: Local Storage & Offline-First Architecture
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

1. **Mengapa Daftar Catatan Tidak Boleh Disimpan di SharedPreferences dan Dampak Pelanggarannya**:
   - SharedPreferences hanya dirancang untuk nilai primitif kecil (tema, bahasa, waktu terakhir dibuka), bukan koleksi data.
   - Jika daftar catatan disimpan sebagai satu string JSON, setiap tambah/hapus menuntut baca-tulis seluruh daftar, tidak ada query parsial (urut/filter), dan sinkronisasi menjadi lambat serta rawan korup saat data bertambah.

2. **Kapan Cache-First Cukup dan Kapan Butuh Strategi Lain**:
   - Cache-first cukup untuk data yang jarang berubah dan toleran tampil sedikit lama (daftar catatan, artikel), sehingga UI tampil instan tanpa menunggu jaringan.
   - Strategi lain (network-first) diperlukan saat data harus selalu segar seperti harga real-time atau saldo, karena menampilkan cache lama berisiko menyesatkan pengguna.

3. **Bagaimana Dirty Flag Menjadi Antrean Sync Tanpa Memblokir UI dan Kapan Outbox Perlu**:
   - Perubahan lokal hanya menandai `dirty = 1` dan langsung selesai dari sisi UI; proses kirim ke server berjalan terpisah (`syncNotes`) lalu `markAllSynced`, sehingga UI tidak menunggu jaringan.
   - Tabel outbox terpisah menjadi perlu saat tiap operasi harus dikirim berurutan dengan penanganan gagal/retry per-operasi, bukan sekadar penanda status pada catatan.

4. **Bagian Rekomendasi AI yang Ditolak dan Alasannya**:
   - Rekomendasi memakai Drift/Hive untuk catatan ditolak karena menambah kompleksitas (codegen/`build_runner`, adapter) tanpa manfaat nyata untuk kebutuhan CRUD + antrean sync sederhana.
   - Klaim "real-time" tanpa dukungan stream juga ditolak; reaktivitas hanya sah bila didukung `watch` (Drift) atau `ref.invalidate` (Riverpod).
