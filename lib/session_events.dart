import 'package:flutter/foundation.dart';

/// Incrementado sempre que uma requisição autenticada retorna 401/403 (token
/// ausente, inválido ou expirado), para que a tela raiz desloque o usuário
/// de volta para o login em vez de deixá-lo preso em telas que nunca
/// conseguem carregar dados.
final ValueNotifier<int> sessionExpiredNotifier = ValueNotifier(0);
