import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/clube.dart';
import '../../services/api_exception.dart';
import '../../services/clube_service.dart';
import '../../theme/app_colors.dart';

Future<bool?> showCreateClubSheet(BuildContext context, {Clube? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CreateClubSheet(existing: existing),
  );
}

class CreateClubSheet extends StatefulWidget {
  final Clube? existing;

  const CreateClubSheet({super.key, this.existing});

  @override
  State<CreateClubSheet> createState() => _CreateClubSheetState();
}

class _CreateClubSheetState extends State<CreateClubSheet> {
  final _clubeService = ClubeService();

  late final _nomeController = TextEditingController(text: widget.existing?.nome ?? '');
  late final _ruaController = TextEditingController(text: widget.existing?.rua ?? '');
  late final _numeroController = TextEditingController(text: widget.existing?.numero ?? '');
  late final _bairroController = TextEditingController(text: widget.existing?.bairro ?? '');
  late final _cidadeController = TextEditingController(text: widget.existing?.cidade ?? '');
  late final _estadoController = TextEditingController(text: widget.existing?.estado ?? '');
  late final _cepController = TextEditingController(text: widget.existing?.cep ?? '');
  String? _fotoBase64;
  bool _salvando = false;

  bool get _editando => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _fotoBase64 = widget.existing?.fotoBase64;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _fotoBase64 = base64Encode(bytes));
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty ||
        _ruaController.text.trim().isEmpty ||
        _numeroController.text.trim().isEmpty ||
        _bairroController.text.trim().isEmpty ||
        _cidadeController.text.trim().isEmpty ||
        _estadoController.text.trim().isEmpty ||
        _cepController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos do endereço.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      if (_editando) {
        await _clubeService.atualizarClube(
          nome: _nomeController.text.trim(),
          rua: _ruaController.text.trim(),
          numero: _numeroController.text.trim(),
          bairro: _bairroController.text.trim(),
          cidade: _cidadeController.text.trim(),
          estado: _estadoController.text.trim(),
          cep: _cepController.text.trim(),
          fotoBase64: _fotoBase64,
        );
      } else {
        await _clubeService.cadastrarClube(
          nome: _nomeController.text.trim(),
          rua: _ruaController.text.trim(),
          numero: _numeroController.text.trim(),
          bairro: _bairroController.text.trim(),
          cidade: _cidadeController.text.trim(),
          estado: _estadoController.text.trim(),
          cep: _cepController.text.trim(),
          fotoBase64: _fotoBase64,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editando ? 'Não foi possível salvar as alterações.' : 'Não foi possível cadastrar o clube.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
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
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(_editando ? 'Editar Clube' : 'Cadastrar Clube', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _escolherFoto,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  image: _fotoBase64 == null
                      ? null
                      : DecorationImage(image: MemoryImage(base64Decode(_fotoBase64!)), fit: BoxFit.cover),
                ),
                alignment: Alignment.center,
                child: _fotoBase64 == null
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted, size: 28),
                          SizedBox(height: 6),
                          Text('Adicionar foto do clube',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nome do clube', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(hintText: 'Ex: Clube Atlético Jardins'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rua', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(controller: _ruaController),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Número', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(controller: _numeroController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Bairro', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(controller: _bairroController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cidade', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(controller: _cidadeController),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UF', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextField(controller: _estadoController, textCapitalization: TextCapitalization.characters),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('CEP', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(controller: _cepController, keyboardType: TextInputType.number),
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
                    : Text(_editando ? 'Salvar Alterações' : 'Cadastrar Clube'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
