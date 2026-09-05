import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/jogador_service.dart';
import '../../services/ranking_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/player_avatar.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _rankingService = RankingService();
  final _jogadorService = JogadorService();

  bool _carregando = true;
  String? _erro;
  List<RankingEntry> _ranking = [];
  Player? _user;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final results = await Future.wait([
        _rankingService.classificacao(),
        _jogadorService.meuPerfil(),
      ]);
      if (!mounted) return;
      setState(() {
        _ranking = results[0] as List<RankingEntry>;
        _user = results[1] as Player;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar o ranking.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_erro != null || _user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro ?? 'Erro desconhecido.', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _carregar, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    final user = _user!;
    final podium = _ranking.take(3).toList();
    final minhaEntrada = _ranking.where((r) => r.player.id == user.id).toList();
    final userPosition = minhaEntrada.isEmpty ? null : minhaEntrada.first.posicao;

    return RefreshIndicator(
      onRefresh: _carregar,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Temporada 2026',
                        style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('Ranking Global', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 30),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Acompanhe sua posição entre todos os tenistas do NOKE.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (userPosition != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text('POS', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        Text('#$userPosition',
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PlayerAvatar(player: user, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(user.level.label,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${user.points} pts',
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          const SizedBox(height: 28),
          Text('Pódio da Temporada', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (podium.length < 3)
            const Text('Ainda não há jogadores suficientes para o pódio.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _PodiumSpot(player: podium[1].player, place: 2, height: 84)),
                const SizedBox(width: 8),
                Expanded(child: _PodiumSpot(player: podium[0].player, place: 1, height: 106)),
                const SizedBox(width: 8),
                Expanded(child: _PodiumSpot(player: podium[2].player, place: 3, height: 68)),
              ],
            ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text('Classificação Completa', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              const Text('Top jogadores', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          for (final entry in _ranking) ...[
            _RankRow(position: entry.posicao, player: entry.player, isMe: entry.player.id == user.id),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final Player player;
  final int place;
  final double height;

  const _PodiumSpot({required this.player, required this.place, required this.height});

  Color get _color => switch (place) {
        1 => AppColors.gold,
        2 => AppColors.silver,
        _ => AppColors.bronze,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (place == 1) const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 22),
        if (place != 1) const SizedBox(height: 22),
        const SizedBox(height: 4),
        PlayerAvatar(player: player, size: place == 1 ? 56 : 46, showOnlineDot: false),
        const SizedBox(height: 6),
        Text(
          player.name.split(' ').first,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        Text('${player.points} pts', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            border: Border.all(color: _color),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            '$place°',
            style: TextStyle(color: _color, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final int position;
  final Player player;
  final bool isMe;

  const _RankRow({required this.position, required this.player, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMe ? AppColors.primary : AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$position',
                style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          PlayerAvatar(player: player, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMe ? '${player.name} (Você)' : player.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${player.points} pts',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
