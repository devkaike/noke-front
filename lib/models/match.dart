import 'player.dart';

enum CourtType { saibro, quadraDura, grama, carpete }

extension CourtTypeX on CourtType {
  String get label => switch (this) {
        CourtType.saibro => 'Saibro',
        CourtType.quadraDura => 'Quadra Dura',
        CourtType.grama => 'Grama',
        CourtType.carpete => 'Carpete',
      };
}

enum MatchMode { casual, ranqueada }

extension MatchModeX on MatchMode {
  String get label => switch (this) {
        MatchMode.casual => 'Casual',
        MatchMode.ranqueada => 'Ranqueada',
      };
}

enum MatchStatus { aberta, encerrada }

class TennisMatch {
  final String id;
  final String clubName;
  final CourtType court;
  final MatchMode mode;
  final PlayerLevel level;
  final DateTime dateTime;
  final int totalSlots;
  final int filledSlots;
  final Player creator;
  final MatchStatus status;

  const TennisMatch({
    required this.id,
    required this.clubName,
    required this.court,
    required this.mode,
    required this.level,
    required this.dateTime,
    required this.totalSlots,
    required this.filledSlots,
    required this.creator,
    this.status = MatchStatus.aberta,
  });

  int get openSlots => totalSlots - filledSlots;
  bool get isFull => openSlots <= 0;
}
