class Cliente {
  final int id;
  final String razaoSocial;
  final String cnpjCpf;
  final String? telefone;
  final String? email;
  final String? endereco;
  final List<Bomba> bombas;

  Cliente({
    required this.id,
    required this.razaoSocial,
    required this.cnpjCpf,
    this.telefone,
    this.email,
    this.endereco,
    this.bombas = const [],
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    var rawBombas = json['bombas'];
    List<Bomba> bombasList = [];
    if (rawBombas is List) {
      bombasList = rawBombas.map((b) => Bomba.fromJson(b)).toList();
    }

    return Cliente(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      razaoSocial: json['razao_social'] ?? '',
      cnpjCpf: json['cnpj_cpf'] ?? '',
      telefone: json['telefone'],
      email: json['email'],
      endereco: json['endereco'],
      bombas: bombasList,
    );
  }
}

class Bomba {
  final int id;
  final int clienteId;
  final String modelo;
  final String numeroSerie;
  final String? tipo;
  final String? fabricante;
  final String? localizacao;
  final String? tag;

  Bomba({
    required this.id,
    required this.clienteId,
    required this.modelo,
    required this.numeroSerie,
    this.tipo,
    this.fabricante,
    this.localizacao,
    this.tag,
  });

  factory Bomba.fromJson(Map<String, dynamic> json) {
    return Bomba(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      clienteId: json['cliente_id'] is int ? json['cliente_id'] : int.tryParse(json['cliente_id'].toString()) ?? 0,
      modelo: json['modelo'] ?? '',
      numeroSerie: json['numero_serie'] ?? '',
      tipo: json['tipo'],
      fabricante: json['fabricante'],
      localizacao: json['localizacao'],
      tag: json['tag'],
    );
  }

  String get displayName => '${modelo} (Série: $numeroSerie)${tag != null && tag!.isNotEmpty ? " [TAG: $tag]" : ""}';
}
