import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/clube.dart';
import '../../models/match.dart';
import '../../services/api_exception.dart';
import '../../services/clube_service.dart';
import '../../theme/app_colors.dart';

Future<bool?> showCreateCourtSheet(BuildContext context, {Quadra? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CreateCourtSheet(existing: existing),
  );
}

class CreateCourtSheet extends StatefulWidget {
  final Quadra? existing;

  const CreateCourtSheet({super.key, this.existing});

  @override
  State<CreateCourtSheet> createState() => _CreateCourtSheetState();
}

class _CreateCourtSheetState extends State<CreateCourtSheet> {
  final _clubeService = ClubeService();

  late final _nomeController = TextEditingController(text: widget.existing?.nome ?? '');
  late final _observacoesController = TextEditingController(text: widget.existing?.observacoes ?? '');
  late CourtType _tipo = widget.existing?.tipoQuadra ?? CourtType.saibro;
  late bool _coberta = widget.existing?.coberta ?? false;
  late bool _iluminacao = widget.existing?.iluminacao ?? false;
  late final List<String> _fotosBase64 = List.of(widget.existing?.fotosBase64 ?? []);
  bool _salvando = false;

  bool get _editando => widget.existing != null;

  @override
  void dispose() {
    _nomeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _adicionarFotos() async {
    final files = await ImagePicker().pickMultiImage(maxWidth: 1280, imageQuality: 80);
    if (files.isEmpty) return;
    final novas = <String>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      novas.add(base64Encode(bytes));
    }
    if (!mounted) return;
    setState(() => _fotosBase64.addAll(novas));
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da quadra.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      if (_editando) {
        await _clubeService.atualizarQuadra(
          widget.existing!.id,
          nome: _nomeController.text.trim(),
          tipoQuadra: _tipo,
          coberta: _coberta,
          iluminacao: _iluminacao,
          observacoes: _observacoesController.text.trim(),
          fotosBase64: _fotosBase64,
        );
      } else {
        await _clubeService.cadastrarQuadra(
          nome: _nomeController.text.trim(),
          tipoQuadra: _tipo,
          coberta: _coberta,
          iluminacao: _iluminacao,
          observacoes: _observacoesController.text.trim(),
          fotosBase64: _fotosBase64,
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
        SnackBar(content: Text(_editando ? 'Não foi possível salvar as alterações.' : 'Não foi possível cadastrar a quadra.')),
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
            Text(_editando ? 'Editar Quadra' : 'Nova Quadra', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            const Text('Nome', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(hintText: 'Ex: Quadra 1'),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de quadra', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in CourtType.values) _buildChip(tipo.label, _tipo == tipo, () => setState(() => _tipo = tipo)),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Coberta', style: TextStyle(fontSize: 14)),
              value: _coberta,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _coberta = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Iluminação', style: TextStyle(fontSize: 14)),
              value: _iluminacao,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _iluminacao = v),
            ),
            const SizedBox(height: 8),
            const Text('Observações', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _observacoesController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Detalhes adicionais (opcional)'),
            ),
            const SizedBox(height: 16),
            const Text('Fotos', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _fotosBase64.length; i++) _buildFotoThumb(i),
                _buildAddFotoButton(),
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
                    : Text(_editando ? 'Salvar Alterações' : 'Cadastrar Quadra'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoThumb(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            base64Decode(_fotosBase64[index]),
            width: 76,
            height: 76,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _fotosBase64.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddFotoButton() {
    return GestureDetector(
      onTap: _adicionarFotos,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted, size: 22),
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}
