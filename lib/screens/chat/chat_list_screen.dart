import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/player_avatar.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = MockData.conversations;
    final timeFmt = DateFormat('HH:mm');

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mensagens', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                const Text(
                  'Converse com seus parceiros de quadra e combine sua próxima partida.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar tenista pelo nome...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
              itemBuilder: (context, i) {
                final c = conversations[i];
                final last = c.lastMessage;
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatConversationScreen(conversation: c)),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  leading: PlayerAvatar(player: c.player, size: 48),
                  title: Text(c.player.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(
                    last?.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  trailing: last == null
                      ? null
                      : Text(timeFmt.format(last.time),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
