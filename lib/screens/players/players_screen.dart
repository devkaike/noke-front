import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/jogador_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/invite_helper.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/player_profile_sheet.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final _jogadorService = JogadorService();
  final _searchController = TextEditingController();

  PlayerLevel? _levelFilter;
  Timer? _debounce;

  bool _carregando = true;
  String? _erro;
  List<Player> _results = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final players = await _jogadorService.buscar(
        nivel: _levelFilter,
        busca: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _results = players;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os jogadores.';
        _carregando = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _carregar);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Jogadores', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Descubra tenistas e marque uma partida.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Buscar tenista pelo nome...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        label: 'Todos',
                        selected: _levelFilter == null,
                        onTap: () {
                          setState(() => _levelFilter = null);
                          _carregar();
                        },
                      ),
                      for (final l in PlayerLevel.values) ...[
                        const SizedBox(width: 8),
                        _Chip(
                          label: l.label,
                          selected: _levelFilter == l,
                          onTap: () {
                            setState(() => _levelFilter = l);
                            _carregar();
                          },
                        ),
                      ],
                    ],
                  ),
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
                    : _results.isEmpty
                        ? const Center(
                            child: Text('Nenhum jogador encontrado.',
                                style: TextStyle(color: AppColors.textMuted)),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregar,
                            color: AppColors.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: _results.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final p = _results[i];
                                return Card(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => showPlayerProfile(context, p),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          PlayerAvatar(player: p, size: 48),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(p.name,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w700, fontSize: 14)),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${p.level.label} · ${p.points} pts',
                                                  style: const TextStyle(
                                                      color: AppColors.textMuted, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () => enviarConvite(context, p),
                                            child: const Text('Convidar'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

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
