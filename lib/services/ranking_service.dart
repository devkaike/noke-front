import '../models/player.dart';
import 'api_client.dart';

class RankingEntry {
  final int posicao;
  final Player player;

  const RankingEntry({required this.posicao, required this.player});

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      posicao: json['posicao'] as int,
      player: Player.fromJson(json['jogador'] as Map<String, dynamic>),
    );
  }
}

class RankingService {
  final ApiClient _client = ApiClient.instance;

  Future<List<RankingEntry>> classificacao() async {
    final data = await _client.get('/ranking');
    return (data as List).map((e) => RankingEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
