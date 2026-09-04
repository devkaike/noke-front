import '../models/conversation.dart';
import '../models/match.dart';
import '../models/player.dart';

class MockData {
  MockData._();

  static const currentUser = Player(
    id: 'me',
    name: 'Lucas Almeida',
    level: PlayerLevel.avancado,
    points: 1840,
    ranking: 4,
    online: true,
  );

  static final players = <Player>[
    const Player(
      id: 'p1',
      name: 'Lucas Monteiro',
      level: PlayerLevel.intermediario,
      points: 280,
      ranking: 1,
      online: true,
      distanceKm: 1.8,
    ),
    const Player(
      id: 'p2',
      name: 'João Silva',
      level: PlayerLevel.intermediario,
      points: 210,
      ranking: 2,
      online: true,
      distanceKm: 2.3,
    ),
    const Player(
      id: 'p3',
      name: 'Mariana Rocha',
      level: PlayerLevel.avancado,
      points: 340,
      ranking: 3,
      distanceKm: 4.2,
    ),
    const Player(
      id: 'p4',
      name: 'Felipe Nogueira',
      level: PlayerLevel.iniciante,
      points: 95,
      ranking: 5,
      online: true,
      distanceKm: 5.6,
    ),
    const Player(
      id: 'p5',
      name: 'Carla Duarte',
      level: PlayerLevel.profissional,
      points: 610,
      ranking: 0,
      distanceKm: 6.9,
    ),
  ];

  static final matches = <TennisMatch>[
    TennisMatch(
      id: 'm1',
      clubName: 'Clube Atlético Jardins',
      court: CourtType.saibro,
      mode: MatchMode.casual,
      level: PlayerLevel.iniciante,
      dateTime: DateTime(2026, 9, 6, 7, 0),
      totalSlots: 4,
      filledSlots: 2,
      creator: players[0],
    ),
    TennisMatch(
      id: 'm2',
      clubName: 'Quadras do Parque Ibirapuera',
      court: CourtType.quadraDura,
      mode: MatchMode.ranqueada,
      level: PlayerLevel.iniciante,
      dateTime: DateTime(2026, 9, 8, 18, 0),
      totalSlots: 4,
      filledSlots: 1,
      creator: players[1],
    ),
    TennisMatch(
      id: 'm3',
      clubName: 'Grand Slam Arena',
      court: CourtType.carpete,
      mode: MatchMode.ranqueada,
      level: PlayerLevel.profissional,
      dateTime: DateTime(2026, 9, 10, 1, 30),
      totalSlots: 4,
      filledSlots: 1,
      creator: currentUser,
    ),
    TennisMatch(
      id: 'm4',
      clubName: 'Green Court Club',
      court: CourtType.grama,
      mode: MatchMode.ranqueada,
      level: PlayerLevel.profissional,
      dateTime: DateTime(2026, 2, 14, 16, 0),
      totalSlots: 2,
      filledSlots: 2,
      creator: currentUser,
      status: MatchStatus.encerrada,
    ),
    TennisMatch(
      id: 'm5',
      clubName: 'Quadra Olímpica Santos',
      court: CourtType.quadraDura,
      mode: MatchMode.casual,
      level: PlayerLevel.avancado,
      dateTime: DateTime(2026, 3, 25, 9, 0),
      totalSlots: 2,
      filledSlots: 2,
      creator: currentUser,
      status: MatchStatus.encerrada,
    ),
  ];

  static List<TennisMatch> get openMatches =>
      matches.where((m) => m.status == MatchStatus.aberta).toList();

  static List<TennisMatch> get myMatches =>
      matches.where((m) => m.creator.id == currentUser.id).toList();

  static final conversations = <Conversation>[
    Conversation(
      id: 'c1',
      player: players[0],
      messages: [
        ChatMessage(
          text: 'Salve! Bora jogar sábado de manhã?',
          time: DateTime(2026, 9, 3, 9, 12),
          fromMe: false,
        ),
        ChatMessage(
          text: 'Fechou! Que horas e qual quadra?',
          time: DateTime(2026, 9, 3, 9, 14),
          fromMe: true,
        ),
        ChatMessage(
          text: '9h no Clube Pinheiros, saibro. Vai ser bom pra treinar slice.',
          time: DateTime(2026, 9, 3, 9, 15),
          fromMe: false,
        ),
        ChatMessage(
          text: 'Perfeito. Vou criar a partida no app já já.',
          time: DateTime(2026, 9, 3, 9, 17),
          fromMe: true,
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      player: players[1],
      messages: [
        ChatMessage(
          text: 'Valeu pelo jogo de ontem!',
          time: DateTime(2026, 9, 2, 20, 5),
          fromMe: false,
        ),
        ChatMessage(
          text: 'Foi ótimo, revanche semana que vem?',
          time: DateTime(2026, 9, 2, 20, 10),
          fromMe: true,
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      player: players[2],
      messages: [
        ChatMessage(
          text: 'Você viu o ranking dessa temporada?',
          time: DateTime(2026, 9, 1, 12, 0),
          fromMe: false,
        ),
      ],
    ),
  ];
}
