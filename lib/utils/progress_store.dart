import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One serialized document for balance, claims, purchases and records.
/// Legacy keys remain untouched so migration is recoverable.
class ProgressStore {
  static const key = 'night_jump.progress.v1';
  static Future<void> _tail = Future<void>.value();
  static bool _mustReload = false;

  static Future<T> transaction<T>(Future<T> Function(ProgressData) action) {
    final result = _tail.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (_mustReload) {
        await prefs.reload();
        _mustReload = false;
      }
      final saved = prefs.getString(key);
      final data = ProgressData(
        saved == null
            ? {for (final k in prefs.getKeys()) k: prefs.get(k)}
            : Map<String, dynamic>.from(jsonDecode(saved) as Map),
      );
      final value = await action(data);
      try {
        if (!await prefs.setString(key, jsonEncode(data.values))) {
          throw StateError('No se pudo guardar el progreso');
        }
      } catch (_) {
        // Legacy SharedPreferences updates its cache before native storage
        // confirms success. Never let a rejected purchase become persisted by
        // the next read transaction. If reload also fails, block that next
        // transaction until the durable state can be read again.
        _mustReload = true;
        try {
          await prefs.reload();
          _mustReload = false;
        } catch (_) {
          // Keep the original write error and require a reload next time.
        }
        rethrow;
      }
      return value;
    });
    _tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  static Future<void> reset({required Set<String> keysToKeep}) =>
      transaction((data) async {
        final prefs = await SharedPreferences.getInstance();
        for (final oldKey in prefs.getKeys()) {
          if (oldKey != key && !keysToKeep.contains(oldKey)) {
            if (!await prefs.remove(oldKey)) {
              throw StateError('No se pudo restablecer el progreso');
            }
          }
        }
        // Keep an empty document rather than deleting it and re-importing
        // legacy keys. Subsequent rewards remain inside the same queue.
        data.values.clear();
      });
}

class ProgressData {
  ProgressData(this.values);
  final Map<String, dynamic> values;
  int? getInt(String key) => values[key] as int?;
  bool? getBool(String key) => values[key] as bool?;
  String? getString(String key) => values[key] as String?;
  List<String>? getStringList(String key) =>
      (values[key] as List?)?.cast<String>();
  Future<void> setInt(String key, int value) async => values[key] = value;
  Future<void> setBool(String key, bool value) async => values[key] = value;
  Future<void> setString(String key, String value) async => values[key] = value;
  Future<void> setStringList(String key, List<String> value) async =>
      values[key] = value;
  Future<void> remove(String key) async => values.remove(key);
}
