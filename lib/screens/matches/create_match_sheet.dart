import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../services/api_exception.dart';
import '../../services/partida_service.dart';
import '../../theme/app_colors.dart';

class CreateMatchSheet extends StatefulWidget {
  final TennisMatch? existing;

  const CreateMatchSheet({super.key, this.existing});

  @override
  State<CreateMatchSheet> createState() => _CreateMatchSheetState();
}

class _CreateMatchSheetState extends State<CreateMatchSheet> {
  late final _clubController = TextEditingController(text: widget.existing?.clubName ?? '');
  final _partidaService = PartidaService();

  late CourtType _court = widget.existing?.court ?? CourtType.saibro;
  late PlayerLevel _level = widget.existing?.level ?? PlayerLevel.iniciante;
  late MatchMode _mode = widget.existing?.mode ?? MatchMode.casual;
  late int _slots = widget.existing?.totalSlots ?? 4;
  late DateTime _dataHora = widget.existing?.dateTime ?? DateTime.now().add(const Duration(days: 1, hours: 1));
  bool _salvando = false;

  bool get _editando => widget.existing != null;

  @override
  void dispose() {
    _clubController.dispose();
    super.dispose();
  }

  Future<void> _escolherDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora),
    );
    if (hora == null) return;

    setState(() {
      _dataHora = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
    });
  }

  Future<void> _salvar() async {
    if (_clubController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o clube ou local da partida.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      if (_editando) {
        await _partidaService.atualizar(
          widget.existing!.id,
          clube: _clubController.text.trim(),
          quadra: _court,
          modo: _mode,
          nivel: _level,
          dataHora: _dataHora,
          vagasTotais: _slots,
        );
      } else {
        await _partidaService.criar(
          clube: _clubController.text.trim(),
          quadra: _court,
          modo: _mode,
          nivel: _level,
          dataHora: _dataHora,
          vagasTotais: _slots,
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
        SnackBar(content: Text(_editando ? 'Não foi possível salvar as alterações.' : 'Não foi possível criar a partida.')),
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
          Text(_editando ? 'Editar Partida' : 'Criar Partida', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          const Text('Clube / Local', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _clubController,
            decoration: const InputDecoration(hintText: 'Ex: Clube Atlético Jardins'),
          ),
          const SizedBox(height: 16),
          const Text('Tipo de quadra', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _SegmentedRow<CourtType>(
            values: CourtType.values,
            selected: _court,
            labelOf: (c) => c.label,
            onSelected: (c) => setState(() => _court = c),
          ),
          const SizedBox(height: 16),
          const Text('Nível exigido', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _SegmentedRow<PlayerLevel>(
            values: PlayerLevel.values,
            selected: _level,
            labelOf: (l) => l.label,
            onSelected: (l) => setState(() => _level = l),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Modo', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    _SegmentedRow<MatchMode>(
                      values: MatchMode.values,
                      selected: _mode,
                      labelOf: (m) => m.label,
                      onSelected: (m) => setState(() => _mode = m),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Data e horário', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _escolherDataHora,
            icon: const Icon(Icons.calendar_today_rounded, size: 16),
            label: Text(DateFormat("d 'de' MMM 'às' HH:mm", 'pt_BR').format(_dataHora)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Vagas', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              IconButton(
                onPressed: _slots > 2 ? () => setState(() => _slots--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_slots', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              IconButton(
                onPressed: _slots < 8 ? () => setState(() => _slots++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
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
                  : Text(_editando ? 'Salvar Alterações' : 'Criar Partida'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedRow<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  const _SegmentedRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(labelOf(v)),
            selected: v == selected,
            onSelected: (_) => onSelected(v),
            selectedColor: AppColors.primaryContainer,
            labelStyle: TextStyle(
              color: v == selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: v == selected ? FontWeight.w700 : FontWeight.w500,
            ),
            side: BorderSide(color: v == selected ? AppColors.primary : AppColors.border),
            backgroundColor: AppColors.surfaceElevated,
          ),
      ],
    );
  }
}
