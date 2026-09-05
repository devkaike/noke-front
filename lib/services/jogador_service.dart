import '../models/player.dart';
import 'api_client.dart';

class JogadorService {
  final ApiClient _client = ApiClient.instance;

  static Player? _cached;
  static Player? get cachedMe => _cached;
  static void clearCache() => _cached = null;

  Future<Player> meuPerfil({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;
    final data = await _client.get('/jogadores/me');
    _cached = Player.fromJson(data as Map<String, dynamic>);
    return _cached!;
  }

  Future<Player> atualizarPerfil({required String nome, required PlayerLevel nivel}) async {
    final data = await _client.put('/jogadores/me', body: {
      'nome': nome,
      'nivel': nivel.apiValue,
    });
    _cached = Player.fromJson(data as Map<String, dynamic>);
    return _cached!;
  }

  Future<List<Player>> buscar({
    PlayerLevel? nivel,
    String? busca,
    double? lat,
    double? lng,
    double? raioKm,
  }) async {
    final params = <String, String>{};
    if (nivel != null) params['nivel'] = nivel.apiValue;
    if (busca != null && busca.isNotEmpty) params['busca'] = busca;
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (raioKm != null) params['raioKm'] = raioKm.toString();

    final query = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    final data = await _client.get('/jogadores$query');
    return (data as List).map((e) => Player.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> atualizarLocalizacao(double latitude, double longitude) async {
    await _client.put('/jogadores/me/localizacao', body: {
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}
