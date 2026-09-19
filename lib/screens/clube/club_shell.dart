import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'club_courts_screen.dart';
import 'club_profile_screen.dart';

class ClubShell extends StatefulWidget {
  final VoidCallback onLogout;

  const ClubShell({super.key, required this.onLogout});

  @override
  State<ClubShell> createState() => _ClubShellState();
}

class _ClubShellState extends State<ClubShell> {
  int _index = 0;

  late final _screens = [
    ClubProfileScreen(onLogout: widget.onLogout),
    const ClubCourtsScreen(),
  ];

  static const _destinations = [
    (icon: Icons.storefront_outlined, selectedIcon: Icons.storefront_rounded, label: 'Meu Clube'),
    (icon: Icons.sports_tennis_outlined, selectedIcon: Icons.sports_tennis_rounded, label: 'Quadras'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final screen = _screens[_index];

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 220,
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
                          const SizedBox(width: 8),
                          Text('MABOKEE',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(letterSpacing: 1, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Painel do Clube',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 24),
                      for (var i = 0; i < _destinations.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: i == _index ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() => _index = i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      i == _index ? _destinations[i].selectedIcon : _destinations[i].icon,
                                      size: 20,
                                      color: i == _index ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _destinations[i].label,
                                      style: TextStyle(
                                        color: i == _index ? AppColors.primary : AppColors.textSecondary,
                                        fontWeight: i == _index ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
            onTap: (i) => setState(() => _index = i),
            items: [
              for (final d in _destinations)
                BottomNavigationBarItem(icon: Icon(d.icon), activeIcon: Icon(d.selectedIcon), label: d.label),
            ],
          ),
        );
      },
    );
  }
}
