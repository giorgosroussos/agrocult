// CMP-AppCatalogue MUST only depend on CMP-AppCore (design/model/architecture.yaml).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _featureDir = 'lib/features/catalogue';

final _import = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  final files = Directory(_featureDir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('the catalogue feature exists', () => expect(files, isNotEmpty));

  test('CMP-AppCatalogue imports no other feature', () {
    final offenders = <String>[];
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final match in _import.allMatches(source)) {
        final uri = match.group(1)!;
        final resolved = uri.startsWith('package:agrocult/')
            ? 'lib/${uri.substring('package:agrocult/'.length)}'
            : uri.startsWith('package:') || uri.startsWith('dart:')
            ? null
            : File(file.parent.uri.resolve(uri).toFilePath()).path;
        if (resolved == null) continue;
        final normalised = Uri.file(resolved).normalizePath().toFilePath();
        final inFeature = normalised.contains('features/catalogue/');
        final inOtherFeature =
            normalised.contains('lib/features/') && !inFeature;
        if (inOtherFeature) offenders.add('${file.path}: $uri');
      }
    }
    expect(offenders, isEmpty);
  });
}
