# Refleksi Pembelajaran: Minggu 02

- **Topik**: Declarative UI & Responsive Design
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

## 1. Perbedaan Cara Berpikir Imperative dan Declarative saat Membangun UI

- **Imperatif**: Pengembang mengatur langkah-demi-langkah perubahan tampilan secara manual (misal mengambil ID elemen lalu mengubah teks atau warnanya satu per satu saat ada event).
- **Deklaratif**: Pada Flutter, UI dirancang sebagai fungsi langsung dari state ($UI = f(state)$). Pengembang mendeskripsikan bagaimana antarmuka terlihat pada kondisi state tertentu, dan Flutter merekonstruksi subtree tampilan secara otomatis saat `setState()` dipanggil.

---

## 2. Kapan Expanded Membantu dan Kapan Menghasilkan Layout Error

- **Membantu**: Saat diletakkan di dalam `Row` atau `Column` untuk membagi sisa ruang secara proporsional dan mencegah teks atau konten meluap (*render overflow*) melewati batas layar.
- **Menghasilkan Error**: Ketika dipasang di luar parent flex (`Row`, `Column`, `Flex`) atau di dalam kontainer yang tidak memiliki batasan ukuran pasti (*unbounded constraints*), memicu error *ParentDataWidget* atau *RenderFlex unbounded height/width*.

---

## 3. Pengaruh Breakpoint dan Theme terhadap Pengalaman Pengguna (UX)

- **Breakpoint**: Menjamin tata letak tetap nyaman dibaca di berbagai ukuran layar dengan beralih adaptif antara 1 kolom pada layar ponsel sempit dan 2 kolom pada layar lebar/tablet.
- **Theme**: Meningkatkan kenyamanan visual pengguna di lingkungan terang maupun redup (mode terang/gelap), menjaga kontras warna antarmuka tetap terbaca, dan ramah aksesibilitas.

---

## 4. Hal yang Diverifikasi dari Rekomendasi AI setelah Tugas Inti Selesai

- Memastikan widget yang disarankan merupakan komponen resmi dari kanal stabil Flutter SDK tanpa dependensi luar yang tidak diinstruksikan.
- Memverifikasi adaptabilitas tata letak pada dimensi layar sempit (di bawah 600px) agar bebas dari error overflow.
- Memastikan rekomendasi AI tetap mematuhi standar aksesibilitas (`Semantics`) dan lulus seluruh pengujian otomatis (`flutter test`).
