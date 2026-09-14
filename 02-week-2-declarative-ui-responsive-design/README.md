# Laporan Praktikum: Minggu 02 - Declarative UI & Responsive Design

- **Nama Mahasiswa**: Ghazwan Ababil
- **NIM**: 244107020151
- **Repositori**: [244107020151-mobile-course](https://github.com/ghazwanz/244107020151-mobile-course)
- **Status Tugas**: 🔄 _In Progress (Sedang Berjalan)_

---

## 1. Tujuan

Memahami dan melatih penggunaan widget tata letak dasar (`Container`, `Column`, `Row`, `Expanded`, `CircleAvatar`) serta mengamati perilaku ukuran dimensi (_constraints_) dan _overflow_ sebelum membangun dashboard responsif.

---

## 2. Praktikum: Layout Sederhana (Warm-up)

Praktikum ini membuat kartu profil sederhana (_ProfileCard_) pada file `lib/main.dart` menggunakan kombinasi `Container`, `Column`, dan `Row`.

### Kode Implementasi

```dart
import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: ProfileCard()),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nama Mahasiswa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Ghazwan Ababil'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: Text('NIM')),
              Text('244107020151'),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Expanded(child: Text('Kelas')),
              Text('TI-3E'),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Expanded(child: Text('Email')),
              Flexible(
                child: Text(
                  'ababilghazwan@gmail.com',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

![Tampilan Awal Kartu Profil](./screenshots/01-profile-card-awal.png)

---

### Hasil Eksperimen Warm-up

1. **Eksperimen 1: Menghapus `Expanded` pada baris nama**
   - Widget `Expanded` berfungsi untuk mengisi sisa ruang horizontal yang tersedia di dalam `Row`.
   - Ketika `Expanded` dihapus, `Column` teks nama akan mengambil lebar menyesuaikan dengan lebar isi teks (child), sehingga teks nama yang panjang menyebabkan _layout overflow_.

   ![Eksperimen 1: tanpa Expanded](./screenshots/02-eksperimen-overflow.png)

2. **Eksperimen 2: Mengganti `mainAxisSize: MainAxisSize.min` ke nilai default (`MainAxisSize.max`)**
   - Secara default, nilai `mainAxisSize` pada `Column` adalah `MainAxisSize.max`.
   - Ketika `mainAxisSize` diubah menjadi `MainAxisSize.max` (atau dihapus), kartu profil akan memanjang vertikal mengambil seluruh ruang tinggi layar yang tersedia. Sebaliknya, `MainAxisSize.min` membuat tinggi kartu menyesuaikan dengan isi konten.

   ![Eksperimen 2: Column MainAxisSize Default](./screenshots/03-eksperimen-mainaxis.png)

3. **Eksperimen 3: Menambahkan satu baris data (Email) dengan pola `Row` + `Expanded`**
   - Menambahkan baris email dengan pola `Row` + `Expanded(child: Text('Email'))` menghasilkan perataan yang konsisten: teks label `'Email'` mengambil ruang fleksibel di sisi kiri, dan nilai email berada di sisi kanan.
   - Selain itu, membungkus nilai email dengan `Flexible` dan `overflow: TextOverflow.ellipsis` mencegah teks panjang meluap (_overflow_) melewati batas lebar kontainer kartu.

   ![Eksperimen 3: Penambahan Baris Email](./screenshots/04-eksperimen-email.png)
