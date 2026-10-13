import 'package:flutter/services.dart';

/// Finds the app-private directory for the database file.
///
/// Asks the host app over a method channel (implemented in MainActivity.kt
/// and AppDelegate.swift), so no extra plugin is needed.
class DatabaseLocation {
  const DatabaseLocation();

  static const channel = MethodChannel('gr.agrocult/app_paths');

  Future<String> directory() async {
    final path = await channel.invokeMethod<String>('databaseDirectory');
    if (path == null || path.isEmpty) {
      throw StateError('The host app returned no database directory');
    }
    return path;
  }
}
