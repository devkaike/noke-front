import '../models/player.dart';
import '../models/ranking_class.dart';
import 'api_client.dart';

class RankingEntry {
  final int posicao;
  final Player player;
  final ClasseRanking classe;
  final NivelClasse? nivel;

  const RankingEntry({
    required this.posicao,
    required this.player,
    required this.classe,
    this.nivel,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      posicao: json['posicao'] as int,
      player: Player.fromJson(json['jogador'] as Map<String, dynamic>),
      classe: ClasseRankingX.fromApi(json['classe'] as String),
      nivel: json['nivel'] == null ? null : NivelClasseX.fromApi(json['nivel'] as String),
    );
  }
}

class RankingService {
  final ApiClient _client = ApiClient.instance;

  Future<List<RankingEntry>> classificacao({ClasseRanking? classe, NivelClasse? nivel}) async {
    final params = <String, String>{};
    if (classe != null) params['classe'] = classe.apiValue;
    if (nivel != null) params['nivel'] = nivel.apiValue;

    final query = params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
    final data = await _client.get('/ranking$query');
    return (data as List).map((e) => RankingEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
