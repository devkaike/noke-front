enum FormatoResultado { sets, proSet, woCuringa }

extension FormatoResultadoX on FormatoResultado {
  String get label => switch (this) {
        FormatoResultado.sets => 'Sets',
        FormatoResultado.proSet => 'Pró-Set',
        FormatoResultado.woCuringa => 'WO / Curinga',
      };

  String get apiValue => switch (this) {
        FormatoResultado.sets => 'SETS',
        FormatoResultado.proSet => 'PRO_SET',
        FormatoResultado.woCuringa => 'WO_CURINGA',
      };

  static FormatoResultado fromApi(String value) => switch (value) {
        'SETS' => FormatoResultado.sets,
        'PRO_SET' => FormatoResultado.proSet,
        'WO_CURINGA' => FormatoResultado.woCuringa,
        _ => FormatoResultado.sets,
      };
}
