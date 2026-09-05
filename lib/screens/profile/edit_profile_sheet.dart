import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/api_exception.dart';
import '../../services/jogador_service.dart';
import '../../theme/app_colors.dart';

class EditProfileSheet extends StatefulWidget {
  final Player user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _jogadorService = JogadorService();
  late final _nomeController = TextEditingController(text: widget.user.name);
  late PlayerLevel _nivel = widget.user.level;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um nome válido.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await _jogadorService.atualizarPerfil(nome: _nomeController.text.trim(), nivel: _nivel);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar seu perfil.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 18),
          Text('Editar Perfil', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          const Text('Nome', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(controller: _nomeController),
          const SizedBox(height: 16),
          const Text('Nível', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in PlayerLevel.values)
                ChoiceChip(
                  label: Text(l.label),
                  selected: l == _nivel,
                  onSelected: (_) => setState(() => _nivel = l),
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceElevated,
                  side: BorderSide(color: l == _nivel ? AppColors.primary : AppColors.border),
                  labelStyle: TextStyle(
                    color: l == _nivel ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: l == _nivel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}
