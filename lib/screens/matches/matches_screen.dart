import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../services/api_exception.dart';
import '../../services/partida_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import '../../widgets/match_details_sheet.dart';
import 'create_match_sheet.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final _partidaService = PartidaService();

  CourtType? _courtFilter;
  PlayerLevel? _levelFilter;

  bool _carregando = true;
  String? _erro;
  List<TennisMatch> _matches = [];

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
      final matches = await _partidaService.abertas(quadra: _courtFilter, nivel: _levelFilter);
      if (!mounted) return;
      setState(() {
        _matches = matches;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as partidas.';
        _carregando = false;
      });
    }
  }

  Future<void> _openCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateMatchSheet(),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida criada com sucesso!')),
      );
      _carregar();
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
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Partidas Abertas', style: Theme.of(context).textTheme.titleLarge),
                      const Text('Encontre, entre e jogue.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _openCreateSheet,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Criar'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todas as quadras',
                    selected: _courtFilter == null,
                    onTap: () {
                      setState(() => _courtFilter = null);
                      _carregar();
                    },
                  ),
                  for (final c in CourtType.values) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: c.label,
                      selected: _courtFilter == c,
                      onTap: () {
                        setState(() => _courtFilter = c);
                        _carregar();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos os níveis',
                    selected: _levelFilter == null,
                    onTap: () {
                      setState(() => _levelFilter = null);
                      _carregar();
                    },
                  ),
                  for (final l in PlayerLevel.values) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l.label,
                      selected: _levelFilter == l,
                      onTap: () {
                        setState(() => _levelFilter = l);
                        _carregar();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _erro != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_erro!, style: const TextStyle(color: AppColors.textMuted)),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _carregar, child: const Text('Tentar novamente')),
                          ],
                        ),
                      )
                    : _matches.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma partida encontrada com esses filtros.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregar,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: _matches.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, i) => MatchCard(
                                match: _matches[i],
                                onJoin: () => _participar(_matches[i]),
                                onDetails: () => showMatchDetails(context, _matches[i].id),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}
