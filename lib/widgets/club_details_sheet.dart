import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/clube.dart';
import '../models/match.dart';
import '../services/clube_publico_service.dart';
import '../theme/app_colors.dart';

Future<void> showClubDetails(BuildContext context, String clubeId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ClubDetailsSheet(clubeId: clubeId),
  );
}

class ClubDetailsSheet extends StatefulWidget {
  final String clubeId;

  const ClubDetailsSheet({super.key, required this.clubeId});

  @override
  State<ClubDetailsSheet> createState() => _ClubDetailsSheetState();
}

class _ClubDetailsSheetState extends State<ClubDetailsSheet> {
  final _clubePublicoService = ClubePublicoService();

  bool _carregando = true;
  String? _erro;
  Clube? _clube;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final clube = await _clubePublicoService.detalhe(widget.clubeId);
      if (!mounted) return;
      setState(() {
        _clube = clube;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os detalhes do clube.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: _carregando
            ? const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            : _erro != null || _clube == null
                ? SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(_erro ?? 'Erro', style: const TextStyle(color: AppColors.textMuted)),
                    ),
                  )
                : SingleChildScrollView(child: _buildContent(_clube!)),
      ),
    );
  }

  Widget _buildContent(Clube clube) {
    final quadras = clube.quadras ?? const [];

    return Column(
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
        Text(clube.nome, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${clube.enderecoCompleto}\nCEP ${clube.cep}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Quadras', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (quadras.isEmpty)
          const Text('Este clube ainda não cadastrou quadras.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13))
        else
          for (final quadra in quadras) _QuadraTile(quadra: quadra),
      ],
    );
  }
}

class _QuadraTile extends StatelessWidget {
  final Quadra quadra;

  const _QuadraTile({required this.quadra});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quadra.nome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 6),
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
            Text(quadra.observacoes!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
