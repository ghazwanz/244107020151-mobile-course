import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_architecture/core/format.dart';

void main() {
  test('formatDateTime menghasilkan format ramah baca', () {
    expect(
      formatDateTime(DateTime(2026, 10, 9, 18, 26)),
      '09 Okt 2026, 18:26',
    );
  });

  test('parseStoredDateTime aman untuk nilai kosong/invalid', () {
    expect(parseStoredDateTime(null), isNull);
    expect(parseStoredDateTime(''), isNull);
    expect(parseStoredDateTime('bukan-tanggal'), isNull);
    expect(parseStoredDateTime('2026-09-27T10:00:00.000'), isNotNull);
  });

  test('parseNoteId aman untuk parameter hilang/invalid', () {
    expect(parseNoteId(null), 0);
    expect(parseNoteId('abc'), 0);
    expect(parseNoteId('12'), 12);
  });
}
