import 'package:flutter/material.dart';
import '../../app_messenger.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

class RegisterClubeScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const RegisterClubeScreen({super.key, required this.onAuthenticated});

  @override
  State<RegisterClubeScreen> createState() => _RegisterClubeScreenState();
}

class _RegisterClubeScreenState extends State<RegisterClubeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _authService = AuthService();

  bool _senhaVisivel = false;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      final nome = _nomeController.text.trim();
      await _authService.registrarClube(
        nome: nome,
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (!mounted) return;
      widget.onAuthenticated();
      Navigator.of(context).pop();
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Conta de clube criada! Agora cadastre os dados do seu clube.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar meu clube')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Conta do clube',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
                    const SizedBox(height: 4),
                    const Text(
                      'Crie a conta responsável pelo clube. Depois de entrar, você cadastra o endereço, a foto e as quadras.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 28),
                    const Text('Nome do responsável',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        hintText: 'Quem vai gerenciar o clube?',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) return 'Informe o nome do responsável';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('E-mail', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'clube@exemplo.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.textMuted),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
                        if (!value.contains('@')) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Senha', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        hintText: 'Mínimo de 8 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 8) return 'Mínimo de 8 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Confirmar senha', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmarSenhaController,
                      obscureText: !_senhaVisivel,
                      decoration: const InputDecoration(
                        hintText: 'Repita a senha',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                      ),
                      validator: (value) {
                        if (value != _senhaController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _carregando ? null : _criarConta,
                      child: _carregando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('Criar conta do clube'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Já tem conta?', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
