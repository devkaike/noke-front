import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import '../../widgets/player_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final myMatches = MockData.myMatches;
    final finished = myMatches.where((m) => m.status == MatchStatus.encerrada).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Row(
            children: [
              Expanded(child: Text('Perfil', style: Theme.of(context).textTheme.titleLarge)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
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
                            Row(
                              children: [
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
                                const SizedBox(width: 6),
                                const Text('Ambos', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(label: 'Pontos', value: '${user.points}'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(label: 'Ranking', value: '#${user.ranking}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: () {}, child: const Text('Editar Perfil')),
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
              Expanded(child: _StatBox(label: 'Partidas', value: '${myMatches.length}')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Encerradas', value: '$finished')),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: 'Vitórias', value: '—')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Minhas Partidas', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Ver feed')),
            ],
          ),
          const SizedBox(height: 12),
          for (final m in myMatches) ...[
            MatchCard(
              match: m,
              onJoin: () {},
              onDetails: () {},
              onEdit: () {},
              onEnd: () {},
            ),
            const SizedBox(height: 12),
          ],
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
