import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/conversation.dart';
import '../../services/api_exception.dart';
import '../../services/chat_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/player_avatar.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatService = ChatService();

  bool _carregando = true;
  String? _erro;
  List<Conversation> _conversations = [];
  List<Conversation> _convites = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final results = await Future.wait([
        _chatService.conversas(),
        _chatService.convitesRecebidos(),
      ]);
      if (!mounted) return;
      setState(() {
        _conversations = results[0];
        _convites = results[1];
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as conversas.';
        _carregando = false;
      });
    }
  }

  Future<void> _aceitar(Conversation convite) async {
    try {
      await _chatService.aceitar(convite.id);
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível aceitar o convite.')),
      );
    }
  }

  Future<void> _recusar(Conversation convite) async {
    try {
      await _chatService.recusar(convite.id);
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível recusar o convite.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _erro != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_erro!, style: const TextStyle(color: AppColors.textMuted)),
                            const SizedBox(height: 12),
                            OutlinedButton(onPressed: _carregar, child: const Text('Tentar novamente')),
                          ],
                        ),
                      )
                    : _convites.isEmpty && _conversations.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma conversa ainda.\nConvide um jogador para começar a trocar mensagens.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregar,
                            color: AppColors.primary,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                              children: [
                                if (_convites.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Text('Convites recebidos',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppColors.textSecondary)),
                                  ),
                                  for (final c in _convites)
                                    Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            PlayerAvatar(player: c.player, size: 44),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(c.player.name,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.w700, fontSize: 13)),
                                                  const Text('Quer se conectar com você',
                                                      style: TextStyle(
                                                          color: AppColors.textMuted, fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _recusar(c),
                                              icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                                              tooltip: 'Recusar',
                                            ),
                                            IconButton(
                                              onPressed: () => _aceitar(c),
                                              icon: const Icon(Icons.check_rounded, color: AppColors.primary),
                                              tooltip: 'Aceitar',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                ],
                                if (_conversations.isNotEmpty) ...[
                                  if (_convites.isNotEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Text('Conversas',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.textSecondary)),
                                    ),
                                  for (final c in _conversations)
                                    ListTile(
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => ChatConversationScreen(conversation: c)),
                                        );
                                        _carregar();
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      leading: PlayerAvatar(player: c.player, size: 48),
                                      title: Text(c.player.name,
                                          style:
                                              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                      subtitle: Text(
                                        c.lastMessage?.text ?? 'Diga olá!',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      ),
                                      trailing: c.lastMessage == null
                                          ? null
                                          : Text(timeFmt.format(c.lastMessage!.time),
                                              style: const TextStyle(
                                                  color: AppColors.textMuted, fontSize: 11)),
                                    ),
                                ],
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
