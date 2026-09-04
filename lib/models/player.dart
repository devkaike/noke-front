enum PlayerLevel { iniciante, intermediario, avancado, profissional }

extension PlayerLevelX on PlayerLevel {
  String get label => switch (this) {
        PlayerLevel.iniciante => 'Iniciante',
        PlayerLevel.intermediario => 'Intermediário',
        PlayerLevel.avancado => 'Avançado',
        PlayerLevel.profissional => 'Profissional',
      };
}

class Player {
  final String id;
  final String name;
  final PlayerLevel level;
  final int points;
  final int ranking;
  final bool online;
  final double? distanceKm;

  const Player({
    required this.id,
    required this.name,
    required this.level,
    required this.points,
    required this.ranking,
    this.online = false,
    this.distanceKm,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }
}
