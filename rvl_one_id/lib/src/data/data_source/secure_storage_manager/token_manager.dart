import 'dart:convert';

import 'package:rvl_one_id/src/data/data_source/secure_storage_manager/secure_storage_manager.dart';
import 'package:rvl_one_id/src/data/model/auth_tokens.dart';

class TokenManger extends SecureStorageManager<String> {
  @override
  String get key => "AuthTokens";

  Future<void> saveAuthTokens({required AuthTokens tokens}) async {
    try {
      final jsonString = jsonEncode(tokens.toJson());

      await saveValue(jsonString);
    } catch (e) {
      throw Exception('Failed to save auth tokens: $e');
    }
  }

  Future<AuthTokens?> getAuthTokens() async {
    try {
      final jsonString = await getValue() ?? "";

      return AuthTokens.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }
}
