class Produto {
  final int id;
  final String codigo;
  final String descricao;
  final double preco;
  final String? unidade;

  Produto({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.preco,
    this.unidade,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      descricao: json['descricao'] ?? json['nome'] ?? '',
      preco: json['preco'] is num 
          ? (json['preco'] as num).toDouble() 
          : double.tryParse(json['preco']?.toString() ?? '0') ?? 0.0,
      unidade: json['unidade'],
    );
  }
}
