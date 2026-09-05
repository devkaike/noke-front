import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // No emulador Android, "localhost" aponta para o próprio dispositivo, não
  // para a máquina host — por isso o endereço especial 10.0.2.2. Em um
  // aparelho físico isso precisaria ser o IP da máquina na rede local.
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static const _tokenKey = 'noke_jwt_token';
  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> _headers({bool auth = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: _headers(auth: auth));
    return _handle(response);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(response);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final status = response.statusCode;
    final bodyText = response.body.isEmpty ? null : utf8.decode(response.bodyBytes);
    final decoded = bodyText == null ? null : jsonDecode(bodyText);

    if (status >= 200 && status < 300) {
      return decoded;
    }

    final message = (decoded is Map && decoded['mensagem'] != null)
        ? decoded['mensagem'] as String
        : 'Erro inesperado (HTTP $status).';
    throw ApiException(status, message);
  }
}
