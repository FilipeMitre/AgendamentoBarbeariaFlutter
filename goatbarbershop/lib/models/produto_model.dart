class ProdutoModel {
  final int id;
  final String nome;
  final String? descricao;
  final double preco;
  final int estoque;
  final String? imagemUrl;
  final bool ativo;
  final bool destaque;
  final String categoriaNome;
  final String categoriaTipo; // 'produto' ou 'bebida'

  ProdutoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.estoque,
    this.imagemUrl,
    this.ativo = true,
    this.destaque = false,
    required this.categoriaNome,
    required this.categoriaTipo,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: (json['preco'] ?? 0).toDouble(),
      estoque: json['estoque'] ?? 0,
      imagemUrl: json['imagem_url'],
      ativo: json['ativo'] == 1 || json['ativo'] == true,
      destaque: json['destaque'] == 1 || json['destaque'] == true,
      categoriaNome: json['categoria_nome'] ?? '',
      categoriaTipo: json['categoria_tipo'] ?? 'produto',
    );
  }
}
