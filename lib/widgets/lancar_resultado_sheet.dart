import 'package:flutter/material.dart';
import '../models/formato_resultado.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/api_exception.dart';
import '../services/resultado_service.dart';
import '../theme/app_colors.dart';

Future<bool?> showLancarResultadoSheet(BuildContext context, TennisMatch match) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => LancarResultadoSheet(match: match),
  );
}

class LancarResultadoSheet extends StatefulWidget {
  final TennisMatch match;

  const LancarResultadoSheet({super.key, required this.match});

  @override
  State<LancarResultadoSheet> createState() => _LancarResultadoSheetState();
}

class _LancarResultadoSheetState extends State<LancarResultadoSheet> {
  final _resultadoService = ResultadoService();

  late FormatoResultado _formato = widget.match.resultado?.formato ?? FormatoResultado.sets;
  late Player _vencedor = widget.match.resultado?.vencedor ?? widget.match.desafiante!;
  late int _totalSets;
  late final List<TextEditingController> _gamesVencedorCtrls;
  late final List<TextEditingController> _gamesPerdedorCtrls;
  bool _salvando = false;

  bool get _editando => widget.match.resultado != null;

  @override
  void initState() {
    super.initState();
    final setsExistentes = widget.match.resultado?.sets ?? const [];
    _totalSets = setsExistentes.length >= 3 ? 3 : 2;
    _gamesVencedorCtrls = List.generate(
      3,
      (i) => TextEditingController(
          text: i < setsExistentes.length ? '${setsExistentes[i].gamesVencedor}' : ''),
    );
    _gamesPerdedorCtrls = List.generate(
      3,
      (i) => TextEditingController(
          text: i < setsExistentes.length ? '${setsExistentes[i].gamesPerdedor}' : ''),
    );
  }

  @override
  void dispose() {
    for (final c in _gamesVencedorCtrls) {
      c.dispose();
    }
    for (final c in _gamesPerdedorCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    final sets = <SetScore>[];
    if (_formato == FormatoResultado.sets) {
      for (var i = 0; i < _totalSets; i++) {
        final gv = int.tryParse(_gamesVencedorCtrls[i].text.trim());
        final gp = int.tryParse(_gamesPerdedorCtrls[i].text.trim());
        if (gv == null || gp == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preencha o placar do ${i + 1}º set.')),
          );
          return;
        }
        sets.add(SetScore(gamesVencedor: gv, gamesPerdedor: gp));
      }
    }

    setState(() => _salvando = true);
    try {
      await _resultadoService.registrar(
        partidaId: widget.match.id,
        formato: _formato,
        vencedorId: _vencedor.id,
        sets: sets,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível registrar o placar.')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    final desafiante = widget.match.desafiante!;
    final desafiado = widget.match.desafiado!;

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
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(_editando ? 'Corrigir Placar' : 'Lançar Placar',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${desafiante.name} (Desafiante) x ${desafiado.name} (Desafiado)',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            if (_editando) ...[
              const SizedBox(height: 6),
              const Text(
                'Correções só são permitidas até 24h após o primeiro lançamento.',
                style: TextStyle(color: AppColors.warning, fontSize: 11),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Formato', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in FormatoResultado.values) _buildChip(f.label, _formato == f, () => setState(() => _formato = f)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Vencedor', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('${desafiante.name} (Desafiante)', _vencedor.id == desafiante.id,
                    () => setState(() => _vencedor = desafiante)),
                _buildChip('${desafiado.name} (Desafiado)', _vencedor.id == desafiado.id,
                    () => setState(() => _vencedor = desafiado)),
              ],
            ),
            if (_formato == FormatoResultado.sets) ...[
              const SizedBox(height: 16),
              const Text('Placar por set (games do vencedor x games do perdedor)',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              for (var i = 0; i < _totalSets; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text('${i + 1}º set', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _gamesVencedorCtrls[i],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Vencedor'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('x', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _gamesPerdedorCtrls[i],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Perdedor'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_totalSets < 3)
                TextButton.icon(
                  onPressed: () => setState(() => _totalSets = 3),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar 3º set'),
                )
              else
                TextButton.icon(
                  onPressed: () => setState(() => _totalSets = 2),
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Remover 3º set'),
                ),
            ],
            const SizedBox(height: 12),
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
                    : Text(_editando ? 'Salvar Correção' : 'Registrar Placar'),
              ),
            ),
          ],
        ),
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
