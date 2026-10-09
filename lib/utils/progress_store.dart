import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One serialized document for balance, claims, purchases and records.
/// Legacy keys remain untouched so migration is recoverable.
class ProgressStore {
  static const key = 'night_jump.progress.v1';
  static Future<void> _tail = Future<void>.value();

  static Future<T> transaction<T>(Future<T> Function(ProgressData) action) {
    final result = _tail.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(key);
      final data = ProgressData(
        saved == null
            ? {for (final k in prefs.getKeys()) k: prefs.get(k)}
            : Map<String, dynamic>.from(jsonDecode(saved) as Map),
      );
      final value = await action(data);
      if (!await prefs.setString(key, jsonEncode(data.values))) {
        throw StateError('No se pudo guardar el progreso');
      }
      return value;
    });
    _tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  static Future<void> reset() =>
      transaction((data) async => data.values.clear());
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
