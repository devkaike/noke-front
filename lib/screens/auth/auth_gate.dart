import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/nav_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  bool _carregandoSessao = true;
  bool _autenticado = false;

  @override
  void initState() {
    super.initState();
    _restaurarSessao();
  }

  Future<void> _restaurarSessao() async {
    final ok = await _authService.tentarRestaurarSessao();
    if (!mounted) return;
    setState(() {
      _autenticado = ok;
      _carregandoSessao = false;
    });
  }

  void _autenticar() => setState(() => _autenticado = true);

  Future<void> _sair() async {
    await _authService.logout();
    if (!mounted) return;
    setState(() => _autenticado = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoSessao) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!_autenticado) {
      return LoginScreen(onAuthenticated: _autenticar);
    }
    return NavShell(onLogout: _sair);
  }
}
