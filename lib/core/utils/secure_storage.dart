import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
