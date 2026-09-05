import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../services/api_exception.dart';
import '../../services/jogador_service.dart';
import '../../services/location_service.dart';
import '../../services/partida_service.dart';
import '../../services/ranking_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import '../../widgets/match_details_sheet.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/player_options_sheet.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _jogadorService = JogadorService();
  final _partidaService = PartidaService();
  final _rankingService = RankingService();

  bool _carregando = true;
  String? _erro;

  Player? _user;
  int? _posicaoRanking;
  List<Player> _nearby = [];
  List<TennisMatch> _open = [];

  @override
  void initState() {
    super.initState();
    _carregar();
    LocationService.instance.updates.addListener(_carregar);
    LocationService.instance.radiusKm.addListener(_carregar);
  }

  @override
  void dispose() {
    LocationService.instance.updates.removeListener(_carregar);
    LocationService.instance.radiusKm.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final minhaPosicao = LocationService.instance.lastPosition;
      final results = await Future.wait([
        _jogadorService.meuPerfil(),
        _jogadorService.buscar(
          lat: minhaPosicao?.latitude,
          lng: minhaPosicao?.longitude,
          raioKm: minhaPosicao == null ? null : LocationService.instance.radiusKm.value,
        ),
        _partidaService.abertas(),
        _rankingService.classificacao(),
      ]);

      final user = results[0] as Player;
      final players = results[1] as List<Player>;
      final matches = results[2] as List<TennisMatch>;
      final ranking = results[3] as List<RankingEntry>;

      final posicao = ranking.indexWhere((r) => r.player.id == user.id);

      if (!mounted) return;
      setState(() {
        _user = user;
        _posicaoRanking = posicao == -1 ? null : posicao + 1;
        _nearby = players.where((p) => p.id != user.id).take(4).toList();
        _open = matches.take(3).toList();
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar seus dados.';
        _carregando = false;
      });
    }
  }

  Future<void> _participar(TennisMatch match) async {
    try {
      await _partidaService.participar(match.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você entrou na partida em ${match.clubName}!')),
      );
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar na partida.')),
      );
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

    return RefreshIndicator(
      onRefresh: _carregar,
      color: AppColors.primary,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bem-vindo de volta',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      Text(user.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
                    ],
                  ),
                ),
                PlayerAvatar(player: user, size: 48),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${user.points}',
                              style: const TextStyle(
                                  color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 30)),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text('pts', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ),
                        ],
                      ),
                      Text(
                        _posicaoRanking == null
                            ? user.level.label
                            : '${user.level.label} · #$_posicaoRanking no ranking',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ações rápidas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.sports_tennis_rounded,
                    label: 'Jogar Agora',
                    filled: true,
                    onTap: () => widget.onNavigate(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.event_available_rounded,
                    label: 'Agendar Partida',
                    onTap: () => widget.onNavigate(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.emoji_events_outlined,
                    label: 'Ranking',
                    onTap: () => widget.onNavigate(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SectionHeader(title: 'Jogadores por perto', onSeeAll: () => widget.onNavigate(2)),
            const SizedBox(height: 12),
            if (LocationService.instance.permissionDenied)
              const Text(
                'Ative a localização para ver jogadores perto de você.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              )
            else if (_nearby.isEmpty)
              const Text('Ainda não há outros jogadores por perto.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12))
            else
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _nearby.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final p = _nearby[i];
                    return GestureDetector(
                      onTap: () => showPlayerOptions(context, p),
                      child: SizedBox(
                        width: 76,
                        child: Column(
                          children: [
                            PlayerAvatar(player: p, size: 56),
                            const SizedBox(height: 6),
                            Text(
                              p.name.split(' ').first,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              p.distanceKm != null
                                  ? '${p.distanceKm!.toStringAsFixed(1)} km'
                                  : p.level.label,
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 28),
            _SectionHeader(title: 'Partidas em aberto', onSeeAll: () => widget.onNavigate(1)),
            const SizedBox(height: 12),
            if (_open.isEmpty)
              const Text('Nenhuma partida em aberto no momento.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12))
            else
              for (final m in _open) ...[
                MatchCard(
                  match: m,
                  onJoin: () => _participar(m),
                  onDetails: () => showMatchDetails(context, m.id),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        TextButton(onPressed: onSeeAll, child: const Text('Ver todos')),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled ? null : Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: filled ? Colors.black : AppColors.primary, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: filled ? Colors.black : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
