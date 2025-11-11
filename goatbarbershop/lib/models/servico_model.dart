class ServicoModel {
  final int id;
  final String nome;
  final String? descricao;
  final double preco;
  final int duracaoMinutos;
  final bool ativo;

  ServicoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.duracaoMinutos,
    this.ativo = true,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: (json['preco_base'] ?? 0).toDouble(),
      duracaoMinutos: json['duracao_minutos'] ?? 30,
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }
}
