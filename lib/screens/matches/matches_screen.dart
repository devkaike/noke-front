import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import 'create_match_sheet.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  CourtType? _courtFilter;
  PlayerLevel? _levelFilter;

  List<TennisMatch> get _filtered {
    return MockData.openMatches.where((m) {
      if (_courtFilter != null && m.court != _courtFilter) return false;
      if (_levelFilter != null && m.level != _levelFilter) return false;
      return true;
    }).toList();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

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
                    onTap: () => setState(() => _courtFilter = null),
                  ),
                  for (final c in CourtType.values) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: c.label,
                      selected: _courtFilter == c,
                      onTap: () => setState(() => _courtFilter = c),
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
                    onTap: () => setState(() => _levelFilter = null),
                  ),
                  for (final l in PlayerLevel.values) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l.label,
                      selected: _levelFilter == l,
                      onTap: () => setState(() => _levelFilter = l),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma partida encontrada com esses filtros.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => MatchCard(
                      match: results[i],
                      onJoin: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pedido enviado para ${results[i].clubName}!')),
                        );
                      },
                      onDetails: () {},
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
