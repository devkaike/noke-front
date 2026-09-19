import 'match.dart';

enum StatusClube { pendente, aprovado, rejeitado }

extension StatusClubeX on StatusClube {
  String get label => switch (this) {
        StatusClube.pendente => 'Pendente',
        StatusClube.aprovado => 'Aprovado',
        StatusClube.rejeitado => 'Rejeitado',
      };

  static StatusClube fromApi(String value) => switch (value) {
        'PENDENTE' => StatusClube.pendente,
        'APROVADO' => StatusClube.aprovado,
        'REJEITADO' => StatusClube.rejeitado,
        _ => StatusClube.pendente,
      };
}

class Clube {
  final String id;
  final String nome;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? fotoBase64;
  final StatusClube status;
  final String? motivoRejeicao;
  final DateTime criadoEm;
  final DateTime? avaliadoEm;

  const Clube({
    required this.id,
    required this.nome,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.fotoBase64,
    required this.status,
    this.motivoRejeicao,
    required this.criadoEm,
    this.avaliadoEm,
  });

  String get enderecoCompleto => '$rua, $numero - $bairro, $cidade/$estado';

  factory Clube.fromJson(Map<String, dynamic> json) {
    return Clube(
      id: json['id'].toString(),
      nome: json['nome'] as String,
      rua: json['rua'] as String? ?? '',
      numero: json['numero'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['cidade'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      cep: json['cep'] as String? ?? '',
      fotoBase64: json['fotoBase64'] as String?,
      status: StatusClubeX.fromApi(json['status'] as String),
      motivoRejeicao: json['motivoRejeicao'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      avaliadoEm: json['avaliadoEm'] == null ? null : DateTime.parse(json['avaliadoEm'] as String),
    );
  }
}

class Quadra {
  final String id;
  final String clubeId;
  final String nome;
  final CourtType tipoQuadra;
  final bool coberta;
  final bool iluminacao;
  final String? observacoes;
  final List<String> fotosBase64;

  const Quadra({
    required this.id,
    required this.clubeId,
    required this.nome,
    required this.tipoQuadra,
    required this.coberta,
    required this.iluminacao,
    this.observacoes,
    this.fotosBase64 = const [],
  });

  factory Quadra.fromJson(Map<String, dynamic> json) {
    return Quadra(
      id: json['id'].toString(),
      clubeId: json['clubeId'].toString(),
      nome: json['nome'] as String,
      tipoQuadra: CourtTypeX.fromApi(json['tipoQuadra'] as String),
      coberta: json['coberta'] as bool? ?? false,
      iluminacao: json['iluminacao'] as bool? ?? false,
      observacoes: json['observacoes'] as String?,
      fotosBase64: (json['fotosBase64'] as List? ?? []).map((e) => e as String).toList(),
    );
  }
}
