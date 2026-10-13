// Architecture rules of the mobile app (design/model/architecture.yaml).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Approved runtime dependencies (approved_dependencies, mobile). A new one
/// needs a change request; update this list only together with the design.
const approvedRuntime = {
  'flutter_riverpod': '^3.0.0',
  'drift': '^2.28.0',
  'dio': '^5.9.0',
  'intl': '^0.20.0',
  'flutter_map': '^8.0.0',
  'vector_map_tiles': '9.0.0-beta.13',
  'firebase_messaging': '^16.0.0',
  'image_picker': '^1.2.0',
  'flutter_image_compress': '^2.4.0',
  'geolocator': '^14.0.0',
  'flutter_secure_storage': '^9.2.0',
};

/// SDK packages that ship with Flutter itself.
const sdkPackages = {'flutter', 'flutter_localizations'};

/// The only file allowed to use the map packages (GardenLocationMap).
const gardenLocationMapFile = 'lib/features/gardens/garden_location_map.dart';

/// Folders of CMP-AppCore; it may depend on no other component.
const appCoreFolders = ['lib/app/', 'lib/core/', 'lib/l10n/'];

final _import = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

Iterable<File> _dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'));

String _rel(File f) => f.path.replaceAll(r'\', '/').replaceFirst('./', '');

Iterable<String> _imports(File f) =>
    _import.allMatches(f.readAsStringSync()).map((m) => m.group(1)!);

/// Reads the top-level keys of a pubspec section (no YAML package needed).
Map<String, String> _section(List<String> lines, String name) {
  final result = <String, String>{};
  var inside = false;
  String? pending;
  for (final line in lines) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    if (!line.startsWith(' ')) {
      inside = line.startsWith('$name:');
      pending = null;
      continue;
    }
    if (!inside) continue;
    final entry = RegExp(r'^  ([a-z0-9_]+):\s*(.*)$').firstMatch(line);
    if (entry != null) {
      pending = entry.group(1);
      result[pending!] = entry.group(2)!.trim();
    } else if (pending != null && line.trim().startsWith('sdk:')) {
      result[pending] = 'sdk';
    }
  }
  return result;
}

void main() {
  final pubspec = File('pubspec.yaml').readAsLinesSync();

  test('pubspec has exactly the approved runtime dependencies', () {
    final deps = _section(pubspec, 'dependencies');
    final nonSdk = {
      for (final e in deps.entries)
        if (e.value != 'sdk') e.key: e.value,
    };

    expect(nonSdk, approvedRuntime);
    expect(
      deps.keys.where((k) => deps[k] == 'sdk').toSet().difference(sdkPackages),
      isEmpty,
    );
  });

  test('lib/ imports only approved packages', () {
    final allowed = {...approvedRuntime.keys, ...sdkPackages, 'agrocult'};
    final offenders = <String>[];
    for (final file in _dartFiles('lib')) {
      for (final uri in _imports(file)) {
        if (!uri.startsWith('package:')) continue;
        final package = uri.substring(8).split('/').first;
        if (!allowed.contains(package)) offenders.add('${_rel(file)}: $uri');
      }
    }
    expect(offenders, isEmpty);
  });

  test('only GardenLocationMap imports flutter_map or vector_map_tiles', () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib')) {
      if (_rel(file).endsWith(gardenLocationMapFile)) continue;
      for (final uri in _imports(file)) {
        if (uri.startsWith('package:flutter_map/') ||
            uri.startsWith('package:vector_map_tiles/')) {
          offenders.add('${_rel(file)}: $uri');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('CMP-AppCore does not depend on any feature', () {
    final offenders = <String>[];
    for (final folder in appCoreFolders) {
      if (!Directory(folder).existsSync()) continue;
      for (final file in _dartFiles(folder)) {
        for (final uri in _imports(file)) {
          if (uri.startsWith('package:agrocult/features/') ||
              uri.contains('features/')) {
            offenders.add('${_rel(file)}: $uri');
          }
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('the import scanner sees imports (self-check)', () {
    final own = _imports(File('test/architecture_test.dart')).toList();
    expect(own, contains('package:flutter_test/flutter_test.dart'));
  });
}
