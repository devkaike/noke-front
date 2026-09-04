import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;
  final bool showOnlineDot;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 44,
    this.showOnlineDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorFromName(player.name),
                _colorFromName(player.name).withValues(alpha: 0.6),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            player.initials,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.75),
              fontWeight: FontWeight.w800,
              fontSize: size * 0.36,
            ),
          ),
        ),
        if (showOnlineDot && player.online)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Color _colorFromName(String name) {
    const palette = [
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
      Color(0xFFF97316),
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];
    final hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }
}
