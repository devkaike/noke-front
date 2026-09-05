import 'player.dart';

enum CourtType { saibro, quadraDura, grama, carpete }

extension CourtTypeX on CourtType {
  String get label => switch (this) {
        CourtType.saibro => 'Saibro',
        CourtType.quadraDura => 'Quadra Dura',
        CourtType.grama => 'Grama',
        CourtType.carpete => 'Carpete',
      };

  String get apiValue => switch (this) {
        CourtType.saibro => 'SAIBRO',
        CourtType.quadraDura => 'QUADRA_DURA',
        CourtType.grama => 'GRAMA',
        CourtType.carpete => 'CARPETE',
      };

  static CourtType fromApi(String value) => switch (value) {
        'SAIBRO' => CourtType.saibro,
        'QUADRA_DURA' => CourtType.quadraDura,
        'GRAMA' => CourtType.grama,
        'CARPETE' => CourtType.carpete,
        _ => CourtType.saibro,
      };
}

enum MatchMode { casual, ranqueada }

extension MatchModeX on MatchMode {
  String get label => switch (this) {
        MatchMode.casual => 'Casual',
        MatchMode.ranqueada => 'Ranqueada',
      };

  String get apiValue => switch (this) {
        MatchMode.casual => 'CASUAL',
        MatchMode.ranqueada => 'RANQUEADA',
      };

  static MatchMode fromApi(String value) => switch (value) {
        'CASUAL' => MatchMode.casual,
        'RANQUEADA' => MatchMode.ranqueada,
        _ => MatchMode.casual,
      };
}

enum MatchStatus { aberta, encerrada, cancelada }

extension MatchStatusX on MatchStatus {
  static MatchStatus fromApi(String value) => switch (value) {
        'ABERTA' => MatchStatus.aberta,
        'ENCERRADA' => MatchStatus.encerrada,
        'CANCELADA' => MatchStatus.cancelada,
        _ => MatchStatus.aberta,
      };
}

class TennisMatch {
  final String id;
  final String clubName;
  final CourtType court;
  final MatchMode mode;
  final PlayerLevel level;
  final DateTime dateTime;
  final int totalSlots;
  final int openSlots;
  final Player creator;
  final MatchStatus status;
  final List<Player> participants;

  const TennisMatch({
    required this.id,
    required this.clubName,
    required this.court,
    required this.mode,
    required this.level,
    required this.dateTime,
    required this.totalSlots,
    required this.openSlots,
    required this.creator,
    this.status = MatchStatus.aberta,
    this.participants = const [],
  });

  bool get isFull => openSlots <= 0;

  factory TennisMatch.fromJson(Map<String, dynamic> json) {
    return TennisMatch(
      id: json['id'].toString(),
      clubName: json['clube'] as String,
      court: CourtTypeX.fromApi(json['quadra'] as String),
      mode: MatchModeX.fromApi(json['modo'] as String),
      level: PlayerLevelX.fromApi(json['nivel'] as String),
      dateTime: DateTime.parse(json['dataHora'] as String),
      totalSlots: json['vagasTotais'] as int,
      openSlots: json['vagasAbertas'] as int,
      creator: Player.fromJson(json['criador'] as Map<String, dynamic>),
      status: MatchStatusX.fromApi(json['status'] as String),
      participants: (json['participantes'] as List? ?? [])
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
