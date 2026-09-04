import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/player.dart';
import '../../theme/app_colors.dart';
import '../../widgets/player_avatar.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  PlayerLevel? _levelFilter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = MockData.players.where((p) {
      if (_levelFilter != null && p.level != _levelFilter) return false;
      if (_query.isNotEmpty && !p.name.toLowerCase().contains(_query.toLowerCase())) return false;
      return true;
    }).toList()
      ..sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Jogadores', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    const Text('Próximos', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Descubra tenistas perto de você e marque uma partida.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar tenista pelo nome...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        label: 'Todos',
                        selected: _levelFilter == null,
                        onTap: () => setState(() => _levelFilter = null),
                      ),
                      for (final l in PlayerLevel.values) ...[
                        const SizedBox(width: 8),
                        _Chip(
                          label: l.label,
                          selected: _levelFilter == l,
                          onTap: () => setState(() => _levelFilter = l),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text('Nenhum jogador encontrado.', style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = results[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              PlayerAvatar(player: p, size: 48),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.level.label} · ${p.points} pts'
                                      '${p.distanceKm != null ? ' · ${p.distanceKm!.toStringAsFixed(1)} km' : ''}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text('Convidar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

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
