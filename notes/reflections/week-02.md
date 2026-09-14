# Refleksi Pembelajaran: Minggu 02

- **Topik**: Declarative UI & Responsive Design
- **Nama**: Ghazwan Ababil
- **NIM**: 244107020151

---

## 1. Pemahaman Deklaratif vs Imperatif

Pada Flutter, UI dirancang secara deklaratif: tampilan adalah cerminan langsung dari _state_ saat ini ($UI = f(state)$). Kita tidak mengubah elemen antarmuka satu per satu secara manual, melainkan mendeklarasikan struktur tampilan dan membiarkan Flutter merekonstruksi subtree yang berubah secara otomatis saat `setState()` dipanggil.

---

## 2. Kekuatan LayoutBuilder

`LayoutBuilder` membaca batasan ukuran kontainer lokal (_box constraints_), bukan ukuran layar penuh. Ini membuat widget dashboard sangat fleksibel dan dapat digunakan kembali di berbagai ukuran layar maupun orientasi tanpa terikat ukuran jendela global.

---

## 3. Pemisahan Perhatian (Separation of Concerns)

Memisahkan logika state tema di `DashboardApp` (StatefulWidget) dan tampilan antarmuka di `DashboardPage` (StatelessWidget) membuat kode lebih rapi, modular, dan mudah diuji.
