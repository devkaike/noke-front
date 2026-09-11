import 'formato_resultado.dart';
import 'player.dart';

class SetScore {
  final int gamesVencedor;
  final int gamesPerdedor;

  const SetScore({required this.gamesVencedor, required this.gamesPerdedor});

  factory SetScore.fromJson(Map<String, dynamic> json) {
    return SetScore(
      gamesVencedor: json['gamesVencedor'] as int,
      gamesPerdedor: json['gamesPerdedor'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'gamesVencedor': gamesVencedor, 'gamesPerdedor': gamesPerdedor};
}

class MatchResult {
  final FormatoResultado formato;
  final Player vencedor;
  final List<SetScore> sets;
  final bool corrigivel;

  const MatchResult({
    required this.formato,
    required this.vencedor,
    required this.sets,
    required this.corrigivel,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      formato: FormatoResultadoX.fromApi(json['formato'] as String),
      vencedor: Player.fromJson(json['vencedor'] as Map<String, dynamic>),
      sets: (json['sets'] as List? ?? [])
          .map((e) => SetScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      corrigivel: json['corrigivel'] as bool? ?? false,
    );
  }
}

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
  final Player? desafiante;
  final Player? desafiado;
  final MatchResult? resultado;

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
    this.desafiante,
    this.desafiado,
    this.resultado,
  });

  bool get isFull => openSlots <= 0;

  /// Elegível para lançamento de placar de ranking (1x1, posições já congeladas).
  bool get elegivelParaResultado => desafiante != null && desafiado != null;

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
      desafiante:
          json['desafiante'] == null ? null : Player.fromJson(json['desafiante'] as Map<String, dynamic>),
      desafiado: json['desafiado'] == null ? null : Player.fromJson(json['desafiado'] as Map<String, dynamic>),
      resultado:
          json['resultado'] == null ? null : MatchResult.fromJson(json['resultado'] as Map<String, dynamic>),
    );
  }
}
