import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';

class LocationRadiusCard extends StatefulWidget {
  const LocationRadiusCard({super.key});

  @override
  State<LocationRadiusCard> createState() => _LocationRadiusCardState();
}

class _LocationRadiusCardState extends State<LocationRadiusCard> {
  Timer? _debounce;
  bool _atualizando = false;

  void _onChanged(double value) {
    // Atualiza a UI na hora, mas só persiste/recarrega a Home depois que o
    // usuário para de arrastar, para não disparar uma chamada por pixel.
    LocationService.instance.radiusKm.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      LocationService.instance.setRadius(LocationService.instance.radiusKm.value);
    });
  }

  Future<void> _atualizarLocalizacao() async {
    setState(() => _atualizando = true);
    final ok = await LocationService.instance.ensurePermissionAndFetch();
    if (!mounted) return;
    setState(() => _atualizando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Localização atualizada!'
            : 'Não foi possível obter sua localização. Verifique as permissões.'),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Distância de busca', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: _atualizando ? null : _atualizarLocalizacao,
                  icon: _atualizando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  tooltip: 'Atualizar minha localização',
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Raio usado para encontrar jogadores perto de você.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: LocationService.instance.radiusKm,
              builder: (context, radius, _) {
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.surfaceElevated,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withValues(alpha: 0.2),
                        valueIndicatorColor: AppColors.primary,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                      ),
                      child: Slider(
                        value: radius,
                        min: LocationService.minRadiusKm,
                        max: LocationService.maxRadiusKm,
                        divisions: (LocationService.maxRadiusKm - LocationService.minRadiusKm).toInt(),
                        label: '${radius.round()} km',
                        onChanged: _onChanged,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('1 km', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        Text(
                          '${radius.round()} km',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const Text('100 km', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                );
              },
            ),
            if (LocationService.instance.permissionDenied) ...[
              const SizedBox(height: 4),
              const Text(
                'Permissão de localização negada. Toque no ícone acima para tentar de novo.',
                style: TextStyle(color: AppColors.danger, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
