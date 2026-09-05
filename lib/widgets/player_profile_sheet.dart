import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import 'invite_helper.dart';
import 'player_avatar.dart';

Future<void> showPlayerProfile(BuildContext context, Player player) async {
  final result = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => PlayerProfileSheet(player: player),
  );

  if (result == 'convidar' && context.mounted) {
    await enviarConvite(context, player);
  }
}

class PlayerProfileSheet extends StatelessWidget {
  final Player player;

  const PlayerProfileSheet({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),
          PlayerAvatar(player: player, size: 72),
          const SizedBox(height: 12),
          Text(player.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              player.level.label,
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stat(label: 'Pontos', value: '${player.points}'),
              const SizedBox(width: 24),
              _Stat(
                label: 'Distância',
                value: player.distanceKm != null ? '${player.distanceKm!.toStringAsFixed(1)} km' : '—',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop('convidar'),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Convidar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
