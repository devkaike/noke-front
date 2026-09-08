import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../session_events.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // Backend em produção (Render), com PostgreSQL real (Neon).
  static const String baseUrl = 'https://noke-back.onrender.com';

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
    return _handle(response, auth: auth);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(response, auth: auth);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(response, auth: auth);
  }

  dynamic _handle(http.Response response, {required bool auth}) {
    final status = response.statusCode;
    final bodyText = response.body.isEmpty ? null : utf8.decode(response.bodyBytes);
    final decoded = bodyText == null ? null : jsonDecode(bodyText);

    if (status >= 200 && status < 300) {
      return decoded;
    }

    final sessaoExpirada = auth && (status == 401 || status == 403) && _token != null;
    if (sessaoExpirada) {
      _token = null;
      sessionExpiredNotifier.value++;
    }

    final message = (decoded is Map && decoded['mensagem'] != null)
        ? decoded['mensagem'] as String
        : sessaoExpirada
            ? 'Sua sessão expirou. Faça login novamente.'
            : 'Erro inesperado (HTTP $status).';
    throw ApiException(status, message);
  }
}
