import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import 'invite_helper.dart';
import 'player_avatar.dart';
import 'player_profile_sheet.dart';

Future<void> showPlayerOptions(BuildContext context, Player player) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PlayerOptionsSheet(player: player),
  );

  if (!context.mounted || action == null) return;

  switch (action) {
    case 'perfil':
      await showPlayerProfile(context, player);
      break;
    case 'convidar':
      await enviarConvite(context, player);
      break;
  }
}

class _PlayerOptionsSheet extends StatelessWidget {
  final Player player;

  const _PlayerOptionsSheet({required this.player});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PlayerAvatar(player: player, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(player.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
              title: const Text('Ver perfil'),
              onTap: () => Navigator.of(context).pop('perfil'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              title: const Text('Convidar'),
              onTap: () => Navigator.of(context).pop('convidar'),
            ),
          ],
        ),
      ),
    );
  }
}
