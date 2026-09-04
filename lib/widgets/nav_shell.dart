import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/player.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/matches/matches_screen.dart';
import '../screens/players/players_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ranking/ranking_screen.dart';
import '../theme/app_colors.dart';
import 'player_avatar.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavDestinationData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;

  const _NavDestinationData(this.icon, this.selectedIcon, this.label, this.screen);
}

class _NavShellState extends State<NavShell> {
  int _index = 0;

  static final _destinations = <_NavDestinationData>[
    _NavDestinationData(Icons.home_outlined, Icons.home_rounded, 'Home', const HomeScreen()),
    _NavDestinationData(Icons.sports_tennis_outlined, Icons.sports_tennis_rounded, 'Partidas',
        const MatchesScreen()),
    _NavDestinationData(Icons.people_alt_outlined, Icons.people_alt_rounded, 'Jogadores',
        const PlayersScreen()),
    _NavDestinationData(
        Icons.emoji_events_outlined, Icons.emoji_events_rounded, 'Ranking', const RankingScreen()),
    _NavDestinationData(
        Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat', const ChatListScreen()),
    _NavDestinationData(
        Icons.person_outline_rounded, Icons.person_rounded, 'Perfil', const ProfileScreen()),
  ];

  void _onSelect(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final screen = _destinations[_index].screen;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                _SideNav(
                  index: _index,
                  destinations: _destinations,
                  onSelect: _onSelect,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: screen),
              ],
            ),
          );
        }

        return Scaffold(
          body: screen,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: _onSelect,
            items: [
              for (final d in _destinations)
                BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  activeIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  final int index;
  final List<_NavDestinationData> destinations;
  final ValueChanged<int> onSelect;

  const _SideNav({
    required this.index,
    required this.destinations,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return Container(
      width: 240,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 26),
              const SizedBox(width: 8),
              Text(
                'NOKE',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(letterSpacing: 1, fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                PlayerAvatar(player: user, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${user.level.label} · ${user.points} pts',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, i) {
                final d = destinations[i];
                final selected = i == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: selected ? AppColors.primaryContainer : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onSelect(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              selected ? d.selectedIcon : d.icon,
                              size: 20,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              d.label,
                              style: TextStyle(
                                color: selected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Text(
            'NOKE · Tennis Network\nv1.0 · 2026',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}
