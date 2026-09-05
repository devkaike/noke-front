enum PlayerLevel { iniciante, intermediario, avancado, profissional }

extension PlayerLevelX on PlayerLevel {
  String get label => switch (this) {
        PlayerLevel.iniciante => 'Iniciante',
        PlayerLevel.intermediario => 'Intermediário',
        PlayerLevel.avancado => 'Avançado',
        PlayerLevel.profissional => 'Profissional',
      };

  String get apiValue => switch (this) {
        PlayerLevel.iniciante => 'INICIANTE',
        PlayerLevel.intermediario => 'INTERMEDIARIO',
        PlayerLevel.avancado => 'AVANCADO',
        PlayerLevel.profissional => 'PROFISSIONAL',
      };

  static PlayerLevel fromApi(String value) => switch (value) {
        'INICIANTE' => PlayerLevel.iniciante,
        'INTERMEDIARIO' => PlayerLevel.intermediario,
        'AVANCADO' => PlayerLevel.avancado,
        'PROFISSIONAL' => PlayerLevel.profissional,
        _ => PlayerLevel.iniciante,
      };
}

class Player {
  final String id;
  final String name;
  final PlayerLevel level;
  final int points;
  final int? ranking;
  final bool online;
  final double? distanceKm;

  const Player({
    required this.id,
    required this.name,
    required this.level,
    required this.points,
    this.ranking,
    this.online = false,
    this.distanceKm,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'].toString(),
      name: json['nome'] as String,
      level: PlayerLevelX.fromApi(json['nivel'] as String),
      points: json['pontos'] as int,
      online: json['online'] as bool? ?? false,
      distanceKm: (json['distanciaKm'] as num?)?.toDouble(),
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }
}
