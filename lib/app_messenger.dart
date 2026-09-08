import 'package:flutter/material.dart';

/// Chave global do ScaffoldMessenger, usada para mostrar mensagens mesmo
/// logo após uma navegação (quando o context da tela que disparou a ação
/// já pode não ser mais o mais confiável para exibir o SnackBar).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
