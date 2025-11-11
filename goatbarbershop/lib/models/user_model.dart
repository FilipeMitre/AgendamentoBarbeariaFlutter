class UserModel {
  final int? id;
  final String nome;
  final String email;
  final String telefone;
  final String? cpf;
  final String tipoUsuario;
  final bool ativo;
  final DateTime dataCadastro;

  UserModel({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.cpf,
    this.tipoUsuario = 'cliente',
    this.ativo = true,
    DateTime? dataCadastro,
  }) : dataCadastro = dataCadastro ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      cpf: json['cpf'],
      tipoUsuario: json['tipo_usuario'] ?? 'cliente',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
      dataCadastro: json['data_cadastro'] != null
          ? DateTime.parse(json['data_cadastro'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'tipo_usuario': tipoUsuario,
      'ativo': ativo,
      'data_cadastro': dataCadastro.toIso8601String(),
    };
  }
}
