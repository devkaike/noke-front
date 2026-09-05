import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class MatchCard extends StatelessWidget {
  final TennisMatch match;
  final bool isOwner;
  final VoidCallback? onJoin;
  final VoidCallback? onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onEnd;

  const MatchCard({
    super.key,
    required this.match,
    this.isOwner = false,
    this.onJoin,
    this.onDetails,
    this.onEdit,
    this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isAberta = match.status == MatchStatus.aberta;
    final dateFmt = DateFormat("d 'de' MMM 'às' HH:mm", 'pt_BR');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.clubName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isAberta)
                  StatusBadge(
                    label: match.status == MatchStatus.cancelada ? 'Cancelada' : 'Encerrada',
                    color: AppColors.textSecondary,
                    background: AppColors.surfaceElevated,
                  )
                else if (match.mode == MatchMode.ranqueada)
                  const StatusBadge(
                    label: 'Ranqueada',
                    color: AppColors.ranked,
                    background: AppColors.primaryContainer,
                  )
                else
                  const StatusBadge(
                    label: 'Casual',
                    color: AppColors.textSecondary,
                    background: AppColors.surfaceElevated,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Criada por ${match.creator.name}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.calendar_today_rounded, label: dateFmt.format(match.dateTime)),
                _InfoChip(icon: Icons.sports_tennis_rounded, label: match.court.label),
                _InfoChip(icon: Icons.military_tech_outlined, label: match.level.label),
              ],
            ),
            const SizedBox(height: 14),
            if (isOwner)
              Row(
                children: [
                  if (onDetails != null) ...[
                    Expanded(
                      child: OutlinedButton(onPressed: onDetails, child: const Text('Ver detalhes')),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEdit,
                      child: const Text('Editar'),
                    ),
                  ),
                  if (isAberta) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                        ),
                        onPressed: onEnd,
                        child: const Text('Encerrar'),
                      ),
                    ),
                  ],
                ],
              )
            else if (isAberta)
              Row(
                children: [
                  Text(
                    match.isFull ? 'Lotada' : '${match.openSlots} vaga(s)',
                    style: TextStyle(
                      color: match.isFull ? AppColors.textMuted : AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (onDetails != null)
                    TextButton(onPressed: onDetails, child: const Text('Ver detalhes')),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: match.isFull ? null : onJoin,
                    child: const Text('Participar'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Text(
                    match.status == MatchStatus.cancelada ? 'Partida cancelada' : 'Partida encerrada',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const Spacer(),
                  if (onDetails != null)
                    TextButton(onPressed: onDetails, child: const Text('Ver detalhes')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
