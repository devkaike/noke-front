enum ClasseRanking { sexta, quinta, quarta, terceira, segunda, profissional }

extension ClasseRankingX on ClasseRanking {
  String get label => switch (this) {
        ClasseRanking.sexta => '6ª Classe',
        ClasseRanking.quinta => '5ª Classe',
        ClasseRanking.quarta => '4ª Classe',
        ClasseRanking.terceira => '3ª Classe',
        ClasseRanking.segunda => '2ª Classe',
        ClasseRanking.profissional => 'Classe Profissional',
      };

  bool get permiteNivel => this != ClasseRanking.profissional;

  String get apiValue => switch (this) {
        ClasseRanking.sexta => 'SEXTA',
        ClasseRanking.quinta => 'QUINTA',
        ClasseRanking.quarta => 'QUARTA',
        ClasseRanking.terceira => 'TERCEIRA',
        ClasseRanking.segunda => 'SEGUNDA',
        ClasseRanking.profissional => 'PROFISSIONAL',
      };

  static ClasseRanking fromApi(String value) => switch (value) {
        'SEXTA' => ClasseRanking.sexta,
        'QUINTA' => ClasseRanking.quinta,
        'QUARTA' => ClasseRanking.quarta,
        'TERCEIRA' => ClasseRanking.terceira,
        'SEGUNDA' => ClasseRanking.segunda,
        'PROFISSIONAL' => ClasseRanking.profissional,
        _ => ClasseRanking.sexta,
      };
}

enum NivelClasse { a, b }

extension NivelClasseX on NivelClasse {
  String get label => switch (this) {
        NivelClasse.a => 'A',
        NivelClasse.b => 'B',
      };

  String get apiValue => switch (this) {
        NivelClasse.a => 'A',
        NivelClasse.b => 'B',
      };

  static NivelClasse fromApi(String value) => switch (value) {
        'A' => NivelClasse.a,
        'B' => NivelClasse.b,
        _ => NivelClasse.b,
      };
}
