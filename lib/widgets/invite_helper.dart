import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/api_exception.dart';
import '../services/chat_service.dart';

Future<void> enviarConvite(BuildContext context, Player player) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ChatService().convidar(player.id);
    messenger.showSnackBar(
      SnackBar(content: Text('Convite enviado para ${player.name}!')),
    );
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Não foi possível enviar o convite.')),
    );
  }
}
