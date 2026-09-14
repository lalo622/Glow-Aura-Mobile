import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
class TokenStorage {
 static const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true), 
  );
  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';
  

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessKey,  value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  static Future<String?> getAccessToken()  => _storage.read(key: _accessKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
  static Future<String?> getUserId() async {
  final token = await getAccessToken();
  if (token == null) return null;

  final parts = token.split('.');
  if (parts.length != 3) return null;

  final payload = utf8.decode(
    base64Url.decode(base64Url.normalize(parts[1])),
  );

  final claims = jsonDecode(payload) as Map<String, dynamic>;

  return claims[
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
}
}