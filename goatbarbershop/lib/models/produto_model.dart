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
    // Robust parsing: backend may return numbers as strings
    double parsePreco(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
      return 0.0;
    }

    int parseEstoque(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? int.tryParse(v.split('.').first) ?? 0;
      return 0;
    }

    final precoVal = parsePreco(json['preco']);
    final estoqueVal = parseEstoque(json['estoque']);

    String categoriaTipoVal = '';
    try {
      categoriaTipoVal = (json['categoria_tipo'] ?? json['categoriaType'] ?? 'produto').toString().toLowerCase();
    } catch (_) {
      categoriaTipoVal = 'produto';
    }

    // Normalize category type to 'produto' or 'bebida'
    if (categoriaTipoVal.contains('beb')) {
      categoriaTipoVal = 'bebida';
    } else {
      categoriaTipoVal = 'produto';
    }

    return ProdutoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: precoVal,
      estoque: estoqueVal,
      imagemUrl: json['imagem_url'] ?? json['imagemUrl'],
      ativo: json['ativo'] == 1 || json['ativo'] == true || json['ativo']?.toString() == '1',
      destaque: json['destaque'] == 1 || json['destaque'] == true || json['destaque']?.toString() == '1',
      categoriaNome: json['categoria_nome'] ?? json['categoriaNome'] ?? '',
      categoriaTipo: categoriaTipoVal,
    );
  }
}
