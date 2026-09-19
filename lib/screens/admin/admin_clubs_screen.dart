import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../models/clube.dart';
import '../../services/admin_service.dart';
import '../../services/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../widgets/status_badge.dart';

class AdminClubsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminClubsScreen({super.key, required this.onLogout});

  @override
  State<AdminClubsScreen> createState() => _AdminClubsScreenState();
}

class _AdminClubsScreenState extends State<AdminClubsScreen> {
  final _adminService = AdminService();

  bool _carregando = true;
  String? _erro;
  List<Clube> _clubes = [];
  StatusClube? _filtro = StatusClube.pendente;

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
      final clubes = await _adminService.listarClubes(status: _filtro);
      if (!mounted) return;
      setState(() {
        _clubes = clubes;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os clubes.';
        _carregando = false;
      });
    }
  }

  Future<void> _aprovar(Clube clube) async {
    try {
      await _adminService.aprovar(clube.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${clube.nome} aprovado.')),
      );
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _rejeitar(Clube clube) async {
    final motivoController = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rejeitar clube'),
        content: TextField(
          controller: motivoController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Explique o motivo da rejeição'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(motivoController.text.trim()),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
    if (motivo == null || motivo.isEmpty) return;

    try {
      await _adminService.rejeitar(clube.id, motivo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${clube.nome} rejeitado.')),
      );
      _carregar();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  (Color, Color) _corStatus(StatusClube status) => switch (status) {
        StatusClube.pendente => (AppColors.warning, AppColors.warningContainer),
        StatusClube.aprovado => (AppColors.primary, AppColors.primaryContainer),
        StatusClube.rejeitado => (AppColors.danger, AppColors.dangerContainer),
      };

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.desktop_windows_outlined, color: AppColors.textMuted, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'O painel de Super Admin está disponível somente na versão web do Mabokee.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(onPressed: widget.onLogout, child: const Text('Sair da conta')),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                        Text('Aprovação de Clubes', style: Theme.of(context).textTheme.titleLarge),
                        const Text('Painel do Super Admin.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final status in [null, ...StatusClube.values]) ...[
                      _FilterChip(
                        label: status == null ? 'Todos' : status.label,
                        selected: _filtro == status,
                        onTap: () {
                          setState(() => _filtro = status);
                          _carregar();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                      : _clubes.isEmpty
                          ? const Center(
                              child: Text('Nenhum clube encontrado com esse filtro.',
                                  style: TextStyle(color: AppColors.textMuted)),
                            )
                          : RefreshIndicator(
                              onRefresh: _carregar,
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: _clubes.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, i) => _buildClubeCard(_clubes[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubeCard(Clube clube) {
    final (corTexto, corFundo) = _corStatus(clube.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clube.fotoBase64 != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(base64Decode(clube.fotoBase64!), width: 56, height: 56, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_outlined, color: AppColors.textMuted),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clube.nome, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(clube.enderecoCompleto,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                StatusBadge(label: clube.status.label, color: corTexto, background: corFundo),
              ],
            ),
            if (clube.status == StatusClube.pendente) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      onPressed: () => _rejeitar(clube),
                      child: const Text('Rejeitar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _aprovar(clube),
                      child: const Text('Aprovar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
