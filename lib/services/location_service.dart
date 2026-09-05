import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'jogador_service.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  static const _radiusKey = 'noke_search_radius_km';
  static const double defaultRadiusKm = 25;
  static const double minRadiusKm = 1;
  static const double maxRadiusKm = 100;

  final ValueNotifier<double> radiusKm = ValueNotifier(defaultRadiusKm);

  /// Dispara sempre que uma nova posição é obtida (ou a tentativa falha),
  /// para telas como a Home recarregarem a busca por proximidade.
  final ValueNotifier<int> updates = ValueNotifier(0);

  Position? lastPosition;
  bool permissionDenied = false;

  Future<void> loadRadius() async {
    final prefs = await SharedPreferences.getInstance();
    radiusKm.value = prefs.getDouble(_radiusKey) ?? defaultRadiusKm;
  }

  Future<void> setRadius(double km) async {
    radiusKm.value = km.clamp(minRadiusKm, maxRadiusKm);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_radiusKey, radiusKm.value);
  }

  /// Pede permissão de localização (se necessário), busca a posição atual e
  /// envia para o backend. Retorna true se conseguiu obter e enviar a posição.
  Future<bool> ensurePermissionAndFetch() async {
    await loadRadius();

    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      permissionDenied = true;
      updates.value++;
      return false;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      permissionDenied = true;
      updates.value++;
      return false;
    }

    permissionDenied = false;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      lastPosition = position;
      await JogadorService().atualizarLocalizacao(position.latitude, position.longitude);
      updates.value++;
      return true;
    } catch (_) {
      updates.value++;
      return false;
    }
  }
}
