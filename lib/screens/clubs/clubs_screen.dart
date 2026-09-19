import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/clube.dart';
import '../../services/clube_publico_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/club_details_sheet.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final _clubePublicoService = ClubePublicoService();

  bool _carregando = true;
  String? _erro;
  List<Clube> _clubes = [];

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
      final clubes = await _clubePublicoService.listar();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clubes', style: Theme.of(context).textTheme.titleLarge),
                const Text('Conheça os clubes parceiros e suas quadras.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
                            child: Text('Nenhum clube cadastrado ainda.',
                                style: TextStyle(color: AppColors.textMuted)),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregar,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: _clubes.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, i) => _ClubCard(
                                clube: _clubes[i],
                                onTap: () => showClubDetails(context, _clubes[i].id),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Clube clube;
  final VoidCallback onTap;

  const _ClubCard({required this.clube, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (clube.fotoBase64 != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(base64Decode(clube.fotoBase64!), width: 64, height: 64, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.textMuted),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clube.nome, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      clube.enderecoCompleto,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
