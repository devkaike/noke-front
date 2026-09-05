import 'api_client.dart';
import 'jogador_service.dart';

class AuthService {
  final ApiClient _client = ApiClient.instance;

  Future<void> login({required String email, required String senha}) async {
    final data = await _client.post(
      '/auth/login',
      auth: false,
      body: {'email': email, 'senha': senha},
    );
    await _client.saveToken(data['token'] as String);
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await _client.post(
      '/auth/registrar',
      auth: false,
      body: {'nome': nome, 'email': email, 'senha': senha},
    );
    await login(email: email, senha: senha);
  }

  Future<void> logout() {
    JogadorService.clearCache();
    return _client.clearToken();
  }

  Future<bool> tentarRestaurarSessao() async {
    await _client.loadToken();
    return _client.isAuthenticated;
  }
}
