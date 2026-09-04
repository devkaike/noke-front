import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/player.dart';
import '../../theme/app_colors.dart';
import '../../widgets/match_card.dart';
import '../../widgets/player_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final nearby = MockData.players.where((p) => p.online).take(4).toList();
    final open = MockData.openMatches.take(3).toList();

    return SafeArea(
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
                    Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
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
                    Text('${user.level.label} · #${user.ranking} no ranking',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.event_available_rounded,
                  label: 'Agendar Partida',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.emoji_events_outlined,
                  label: 'Ranking',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'Jogadores por perto', onSeeAll: () {}),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: nearby.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final p = nearby[i];
                return SizedBox(
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
                        p.level.label,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'Partidas em aberto', onSeeAll: () {}),
          const SizedBox(height: 12),
          for (final m in open) ...[
            MatchCard(match: m, onJoin: () {}, onDetails: () {}),
            const SizedBox(height: 12),
          ],
        ],
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
