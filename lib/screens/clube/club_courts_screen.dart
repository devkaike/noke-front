import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/clube.dart';
import '../../models/match.dart';
import '../../services/api_exception.dart';
import '../../services/clube_service.dart';
import '../../theme/app_colors.dart';
import 'create_court_sheet.dart';

class ClubCourtsScreen extends StatefulWidget {
  const ClubCourtsScreen({super.key});

  @override
  State<ClubCourtsScreen> createState() => _ClubCourtsScreenState();
}

class _ClubCourtsScreenState extends State<ClubCourtsScreen> {
  final _clubeService = ClubeService();

  bool _carregando = true;
  String? _erro;
  List<Quadra> _quadras = [];

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
      final quadras = await _clubeService.minhasQuadras();
      if (!mounted) return;
      setState(() {
        _quadras = quadras;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.statusCode == 404 ? 'Cadastre seu clube antes de adicionar quadras.' : e.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as quadras.';
        _carregando = false;
      });
    }
  }

  Future<void> _abrirNovaQuadra() async {
    final salvo = await showCreateCourtSheet(context);
    if (salvo == true) _carregar();
  }

  Future<void> _editarQuadra(Quadra quadra) async {
    final salvo = await showCreateCourtSheet(context, existing: quadra);
    if (salvo == true) _carregar();
  }

  Future<void> _removerQuadra(Quadra quadra) async {
    try {
      await _clubeService.removerQuadra(quadra.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quadra "${quadra.nome}" removida.')),
      );
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível remover a quadra.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quadras', style: Theme.of(context).textTheme.titleLarge),
                        const Text('Cadastre e gerencie as quadras do seu clube.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _abrirNovaQuadra,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nova'),
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
                      : _quadras.isEmpty
                          ? const Center(
                              child: Text('Nenhuma quadra cadastrada ainda.',
                                  style: TextStyle(color: AppColors.textMuted)),
                            )
                          : RefreshIndicator(
                              onRefresh: _carregar,
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                                itemCount: _quadras.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, i) => _QuadraCard(
                                  quadra: _quadras[i],
                                  onEdit: () => _editarQuadra(_quadras[i]),
                                  onDelete: () => _removerQuadra(_quadras[i]),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuadraCard extends StatelessWidget {
  final Quadra quadra;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuadraCard({required this.quadra, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(quadra.nome, style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoChip(icon: Icons.sports_tennis_rounded, label: quadra.tipoQuadra.label),
                if (quadra.coberta) const _InfoChip(icon: Icons.roofing_rounded, label: 'Coberta'),
                if (quadra.iluminacao) const _InfoChip(icon: Icons.lightbulb_outline_rounded, label: 'Iluminada'),
              ],
            ),
            if (quadra.observacoes != null && quadra.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(quadra.observacoes!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
            if (quadra.fotosBase64.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: quadra.fotosBase64.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(quadra.fotosBase64[i]),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
