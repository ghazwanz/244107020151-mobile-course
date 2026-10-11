/// Fungsi murni lintas fitur: formatting tanggal dan parsing rute.
///
/// Tanpa dependensi Flutter/package apa pun agar bisa diuji tanpa widget
/// (lihat Refactoring Challenge modul Minggu 7).
const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Memformat `DateTime` ke waktu lokal perangkat menjadi teks ramah baca.
///
/// Contoh keluaran: `09 Okt 2026, 18:26`.
String formatDateTime(DateTime dateTime) {
  // Konversi ke waktu lokal perangkat. Jika `dateTime` bernilai UTC,
  // hasilnya otomatis digeser ke zona waktu lokal.
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = _monthNames[local.month - 1];
  final year = local.year;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day $month $year, $hour:$minute';
}

/// Mengurai nilai ISO8601 dari penyimpanan lokal.
///
/// Mengembalikan `null` bila nilai kosong atau tidak valid, sehingga
/// presentation tidak perlu menyentuh `DateTime.tryParse` langsung.
DateTime? parseStoredDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// Mengurai parameter rute `:id` menjadi int yang aman (default `0`).
int parseNoteId(String? raw) => int.tryParse(raw ?? '') ?? 0;
