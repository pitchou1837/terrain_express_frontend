import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

/// Error returned by the backend (e.g. "Slot already booked")
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._(); // one shared client

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // ---------- Token ----------
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${AppConstants.baseUrl}$path')
          .replace(queryParameters: query);

  // ---------- HTTP methods ----------
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await http.get(_uri(path, query), headers: await _headers());
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(_uri(path),
        headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http.put(_uri(path),
        headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: await _headers());
    return _handle(res);
  }

  // ---------- Response handling ----------
  dynamic _handle(http.Response res) {
    final body =
    res.body.isNotEmpty ? jsonDecode(utf8.decode(res.bodyBytes)) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    // FastAPI sends errors as {"detail": "..."}
    final message = (body is Map && body['detail'] != null)
        ? body['detail'].toString()
        : 'Error ${res.statusCode}';
    throw ApiException(res.statusCode, message);
  }
}