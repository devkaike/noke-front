import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/formato_resultado.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/jogador_service.dart';
import '../services/partida_service.dart';
import '../theme/app_colors.dart';
import 'lancar_resultado_sheet.dart';
import 'player_avatar.dart';
import 'status_badge.dart';

Future<void> showMatchDetails(BuildContext context, String matchId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MatchDetailsSheet(matchId: matchId),
  );
}

class MatchDetailsSheet extends StatefulWidget {
  final String matchId;

  const MatchDetailsSheet({super.key, required this.matchId});

  @override
  State<MatchDetailsSheet> createState() => _MatchDetailsSheetState();
}

class _MatchDetailsSheetState extends State<MatchDetailsSheet> {
  final _partidaService = PartidaService();
  final _jogadorService = JogadorService();

  bool _carregando = true;
  String? _erro;
  TennisMatch? _match;
  Player? _user;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final results = await Future.wait([
        _partidaService.detalhes(widget.matchId),
        _jogadorService.meuPerfil(),
      ]);
      if (!mounted) return;
      setState(() {
        _match = results[0] as TennisMatch;
        _user = results[1] as Player;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os detalhes.';
        _carregando = false;
      });
    }
  }

  Future<void> _abrirLancarPlacar() async {
    final match = _match;
    if (match == null) return;
    final salvo = await showLancarResultadoSheet(context, match);
    if (salvo == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Placar registrado com sucesso!')),
      );
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: _carregando
              ? const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              : _erro != null || _match == null
                  ? SizedBox(
                      height: 160,
                      child: Center(
                        child: Text(_erro ?? 'Erro', style: const TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  : SingleChildScrollView(child: _buildContent(_match!)),
        ),
      ),
    );
  }

  Widget _buildContent(TennisMatch match) {
    final dateFmt = DateFormat("d 'de' MMM 'às' HH:mm", 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(match.clubName, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (match.mode == MatchMode.ranqueada)
              const StatusBadge(
                  label: 'Ranqueada', color: AppColors.ranked, background: AppColors.primaryContainer)
            else
              const StatusBadge(
                  label: 'Casual', color: AppColors.textSecondary, background: AppColors.surfaceElevated),
          ],
        ),
        const SizedBox(height: 4),
        Text('Criada por ${match.creator.name}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 16),
        _DetailRow(icon: Icons.calendar_today_rounded, label: dateFmt.format(match.dateTime)),
        _DetailRow(icon: Icons.sports_tennis_rounded, label: match.court.label),
        _DetailRow(icon: Icons.military_tech_outlined, label: 'Nível ${match.level.label}'),
        _DetailRow(
          icon: Icons.people_alt_outlined,
          label: '${match.participants.length} de ${match.totalSlots} vagas preenchidas',
        ),
        const SizedBox(height: 20),
        Text('Participantes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (match.participants.isEmpty)
          const Text('Ninguém entrou nesta partida ainda.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13))
        else
          for (final p in match.participants)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  PlayerAvatar(player: p, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  Text(p.level.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
        if (match.elegivelParaResultado) ...[
          const SizedBox(height: 20),
          Text('Placar do Confronto', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            '${match.desafiante!.name} (Desafiante) x ${match.desafiado!.name} (Desafiado)',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (match.resultado != null) _buildResultadoResumo(match.resultado!),
          if (_podeLancarPlacar(match)) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _abrirLancarPlacar,
                child: Text(match.resultado == null ? 'Lançar Placar' : 'Corrigir Placar'),
              ),
            ),
          ] else if (match.resultado == null)
            const Text('Aguardando um dos jogadores lançar o placar.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ],
    );
  }

  bool _podeLancarPlacar(TennisMatch match) {
    final user = _user;
    if (user == null) return false;
    final souParticipante = user.id == match.desafiante?.id || user.id == match.desafiado?.id;
    if (!souParticipante) return false;
    return match.resultado == null || match.resultado!.corrigivel;
  }

  Widget _buildResultadoResumo(MatchResult resultado) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Vencedor: ${resultado.vencedor.name}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          if (resultado.sets.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              resultado.sets.map((s) => '${s.gamesVencedor}x${s.gamesPerdedor}').join('  '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          Text(resultado.formato.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
