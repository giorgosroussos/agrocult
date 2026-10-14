import 'package:agrocult/features/catalogue/search/search_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applies the server query rules', () {
    expect(searchWords('Ντομάτα'), ['ντοματα']);
    expect(searchWords('ΒΑΣΙΛΙΚΌΣ'), ['βασιλικοσ']);
    expect(searchWords('βασιλικός'), ['βασιλικοσ']);
    expect(searchWords('Ηδύοσμος'), ['ηδυοσμοσ']);
    expect(searchWords('προϊόν ΰ ΐ'), ['προιον', 'υ', 'ι']);
    expect(searchWords('Crème brûlée'), ['creme', 'brulee']);
    // Combining marks (decomposed input) are dropped as well.
    expect(searchWords('ντομάτα'), ['ντοματα']);
  });

  test('anything but letters and digits separates words', () {
    expect(searchWords('  solanum-lycopersicum, 2 '), [
      'solanum',
      'lycopersicum',
      '2',
    ]);
    expect(searchWords('"*()'), isEmpty);
  });

  test('builds a prefix match of every word', () {
    expect(ftsMatchExpression('Σκόρδο'), '"σκορδο"*');
    expect(ftsMatchExpression('solanum lyc'), '"solanum"* "lyc"*');
    expect(ftsMatchExpression(' - '), isNull);
  });
}
