class BarbeiroModel {
  final int id;
  final String nome;
  final String? foto;
  final double avaliacao;
  final double distancia;
  final String status; // Aberto, Fechado, Em Breve
  final String? endereco;

  BarbeiroModel({
    required this.id,
    required this.nome,
    this.foto,
    required this.avaliacao,
    required this.distancia,
    required this.status,
    this.endereco,
  });

  factory BarbeiroModel.fromJson(Map<String, dynamic> json) {
    return BarbeiroModel(
      id: json['id'],
      nome: json['nome'],
      foto: json['foto'],
      avaliacao: (json['avaliacao'] ?? 0).toDouble(),
      distancia: (json['distancia'] ?? 0).toDouble(),
      status: json['status'] ?? 'Fechado',
      endereco: json['endereco'],
    );
  }
}
