/// Helper format tanggal-waktu yang mengonversi nilai ke waktu lokal
/// (dari UTC bila tersedia) dan menampilkannya dalam format ramah baca.
///
/// Contoh keluaran: `09 Okt 2026, 18:26`.
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
