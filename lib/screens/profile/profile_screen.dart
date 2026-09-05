import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../services/api_exception.dart';
import '../../services/jogador_service.dart';
import '../../services/partida_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import '../../widgets/match_details_sheet.dart';
import '../../widgets/player_avatar.dart';
import '../matches/create_match_sheet.dart';
import 'edit_profile_sheet.dart';
import 'location_radius_card.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _jogadorService = JogadorService();
  final _partidaService = PartidaService();

  bool _carregando = true;
  String? _erro;
  Player? _user;
  List<TennisMatch> _myMatches = [];

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
        _jogadorService.meuPerfil(forceRefresh: true),
        _partidaService.minhas(),
      ]);
      if (!mounted) return;
      setState(() {
        _user = results[0] as Player;
        _myMatches = results[1] as List<TennisMatch>;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar seu perfil.';
        _carregando = false;
      });
    }
  }

  Future<void> _encerrar(TennisMatch match) async {
    try {
      await _partidaService.encerrar(match.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Partida em ${match.clubName} encerrada.')),
      );
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível encerrar a partida.')),
      );
    }
  }

  Future<void> _editarPerfil() async {
    final salvo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileSheet(user: _user!),
    );
    if (salvo == true) {
      _carregar();
    }
  }

  Future<void> _editarPartida(TennisMatch match) async {
    final salvo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateMatchSheet(existing: match),
    );
    if (salvo == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida atualizada com sucesso!')),
      );
      _carregar();
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
    final finished = _myMatches.where((m) => m.status == MatchStatus.encerrada).length;

    return RefreshIndicator(
      onRefresh: _carregar,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Row(
            children: [
              Expanded(child: Text('Perfil', style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configurações em breve.')),
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      PlayerAvatar(player: user, size: 64),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.level.label,
                                style: const TextStyle(
                                    color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _StatBox(label: 'Pontos', value: '${user.points}')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatBox(label: 'Partidas', value: '${_myMatches.length}')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: _editarPerfil, child: const Text('Editar Perfil')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Estatísticas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Partidas criadas', value: '${_myMatches.length}')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Encerradas', value: '$finished')),
            ],
          ),
          const SizedBox(height: 24),
          const LocationRadiusCard(),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Minhas Partidas', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          if (_myMatches.isEmpty)
            const Text('Você ainda não criou nenhuma partida.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12))
          else
            for (final m in _myMatches) ...[
              MatchCard(
                match: m,
                isOwner: true,
                onDetails: () => showMatchDetails(context, m.id),
                onEdit: () => _editarPartida(m),
                onEnd: () => _encerrar(m),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sair da conta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
