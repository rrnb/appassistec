class Usuario {
  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String nivel;
  final String? token;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf,
    required this.nivel,
    this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'],
      nivel: json['nivel'] ?? 'tecnico',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'nivel': nivel,
      'token': token,
    };
  }
}
