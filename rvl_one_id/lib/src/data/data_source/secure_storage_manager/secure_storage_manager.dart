import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageManager<T> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get key;

  Future<void> saveValue(T value) async {
    final String stringValue = switch (value) {
      bool v => v.toString(),
      int v => v.toString(),
      double v => v.toString(),
      String v => v,
      Map() || List() => jsonEncode(value),
      _ => throw ArgumentError(
          'Unsupported type for saving: ${value.runtimeType}',
        ),
    };

    await storage.write(key: key, value: stringValue);
  }

  Future<T?> getValue() async {
    final stringValue = await storage.read(key: key);
    if (stringValue == null) return null;

    try {
      if (T == bool) {
        return (stringValue.toLowerCase() == 'true') as T?;
      } else if (T == int) {
        return int.tryParse(stringValue) as T?;
      } else if (T == double) {
        return double.tryParse(stringValue) as T?;
      } else if (T == String) {
        return stringValue as T?;
      } else if (T.toString().startsWith('Map<')) {
        final decoded = jsonDecode(stringValue);
        if (decoded is Map) {
          return decoded as T?;
        }
        return null;
      } else if (T.toString().startsWith('List<')) {
        final decoded = jsonDecode(stringValue);
        if (decoded is List) {
          return decoded as T?;
        }
        return null;
      } else {
        throw ArgumentError('Unsupported type for getting: $T');
      }
    } catch (e) {
      throw Exception('Failed to get/parse secure config for key "$key": $e');
    }
  }

  Future<void> delete() async {
    await storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await storage.deleteAll();
  }
}
