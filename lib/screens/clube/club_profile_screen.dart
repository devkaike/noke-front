import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/clube.dart';
import '../../services/api_exception.dart';
import '../../services/clube_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/status_badge.dart';
import 'create_club_sheet.dart';

class ClubProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ClubProfileScreen({super.key, required this.onLogout});

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen> {
  final _clubeService = ClubeService();

  bool _carregando = true;
  Clube? _clube;
  String? _erro;

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
      final clube = await _clubeService.meuClube();
      if (!mounted) return;
      setState(() {
        _clube = clube;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _clube = null;
        _erro = e.statusCode == 404 ? null : e.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os dados do clube.';
        _carregando = false;
      });
    }
  }

  Future<void> _abrirFormulario() async {
    final salvo = await showCreateClubSheet(context, existing: _clube);
    if (salvo == true) _carregar();
  }

  (Color, Color) _corStatus(StatusClube status) => switch (status) {
        StatusClube.pendente => (AppColors.warning, AppColors.warningContainer),
        StatusClube.aprovado => (AppColors.primary, AppColors.primaryContainer),
        StatusClube.rejeitado => (AppColors.danger, AppColors.dangerContainer),
      };

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _carregar, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text('Meu Clube', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          if (_clube == null) _buildSemClube() else _buildClube(_clube!),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sair da conta'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemClube() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Você ainda não cadastrou seu clube. Cadastre o endereço e uma foto para começar — depois é só adicionar as quadras.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: _abrirFormulario, child: const Text('Cadastrar meu clube')),
        ),
      ],
    );
  }

  Widget _buildClube(Clube clube) {
    final (corTexto, corFundo) = _corStatus(clube.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (clube.fotoBase64 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(clube.fotoBase64!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(clube.nome, style: Theme.of(context).textTheme.titleMedium),
                ),
                StatusBadge(label: clube.status.label, color: corTexto, background: corFundo),
              ],
            ),
            const SizedBox(height: 6),
            Text(clube.enderecoCompleto, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Text('CEP ${clube.cep}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (clube.status == StatusClube.rejeitado && clube.motivoRejeicao != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.dangerContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Motivo: ${clube.motivoRejeicao}',
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),
            ],
            if (clube.status == StatusClube.pendente) ...[
              const SizedBox(height: 10),
              const Text(
                'Seu clube está em análise pela equipe do Mabokee.',
                style: TextStyle(color: AppColors.warning, fontSize: 12),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: _abrirFormulario, child: const Text('Editar Clube')),
            ),
          ],
        ),
      ),
    );
  }
}
