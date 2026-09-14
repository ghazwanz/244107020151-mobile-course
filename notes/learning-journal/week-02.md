# Jurnal Pembelajaran: Minggu 02

- **Topik**: Declarative UI & Responsive Design
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

Pada praktikum minggu ke-2, fokus pembelajaran diarahkan pada konsep antarmuka deklaratif dan pembangunan antarmuka responsif (_responsive design_) menggunakan Flutter.

Beberapa konsep dan komponen penting yang dipelajari dan diimplementasikan meliputi:

- **Widget Tree Composition**: Menggabungkan `Scaffold`, `AppBar`, `LayoutBuilder`, `Column`, `Container`, `Expanded`, `Card`, dan `GridView.count` untuk menyusun tata letak _Academic Overview_.
- **Responsive Layout**: Menggunakan konstanta breakpoint `const double kWideBreakpoint = 700;` untuk mengatur jumlah kolom `GridView.count` secara dinamis (1 kolom vertikal vs 2 kolom grid).
- **Theme Switching**: Menerapkan Material 3 `ThemeData` dengan `colorSchemeSeed: Colors.indigo`, mendukung transisi dinamis antara `ThemeMode.light` dan `ThemeMode.dark` melalui `CupertinoSwitch`.
- **Aksesibilitas (Semantics)**: Membungkus switch tema dan kartu metrik dengan widget `Semantics` agar mudah diakses oleh pembaca layar (_screen reader_).
- **Automated Testing**: Menulis widget test responsif dengan memanipulasi ukuran layar virtual menggunakan `tester.view.physicalSize` dan `tester.view.devicePixelRatio`.

---

## Kendala & Solusi

1. **Kendala Proporsi Kartu pada Layar Lebar**:
   - Tampilan kartu metrik terasa terlalu tinggi atau gepeng saat dibuka di layar lebar jika aspect ratio dibiarkan statis.
   - **Solusi**: Mengatur `childAspectRatio` secara kondisional (`isWide ? 3.0 : 2.6`) pada `GridView.count` agar kartu tetap proporsional di orientasi portrait maupun landscape.
