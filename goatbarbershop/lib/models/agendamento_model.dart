class AgendamentoModel {
  final int? id;
  final int clienteId;
  final String? clienteNome; // Adicionar
  final int barbeiroId;
  final String barbeiroNome;
  final int servicoId;
  final String servicoNome;
  final DateTime dataAgendamento;
  final String horario;
  final double valorServico;
  final String status;
  final List<ProdutoAgendamento>? produtos;

  AgendamentoModel({
    this.id,
    required this.clienteId,
    this.clienteNome, // Adicionar
    required this.barbeiroId,
    required this.barbeiroNome,
    required this.servicoId,
    required this.servicoNome,
    required this.dataAgendamento,
    required this.horario,
    required this.valorServico,
    this.status = 'confirmado',
    this.produtos,
  });

  double get valorTotal {
    double total = valorServico;
    if (produtos != null) {
      for (var produto in produtos!) {
        total += produto.preco * produto.quantidade;
      }
    }
    return total;
  }

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    return AgendamentoModel(
      id: json['id'],
      clienteId: json['cliente_id'],
      clienteNome: json['cliente_nome'],
      barbeiroId: json['barbeiro_id'],
      barbeiroNome: json['barbeiro_nome'] ?? '',
      servicoId: json['servico_id'],
      servicoNome: json['servico_nome'] ?? '',
      dataAgendamento: DateTime.parse(json['data_agendamento']),
      horario: json['horario'],
      valorServico: double.tryParse(json['valor_servico']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'confirmado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'barbeiro_id': barbeiroId,
      'servico_id': servicoId,
      'data_agendamento': dataAgendamento.toIso8601String(),
      'horario': horario,
      'produtos': produtos?.map((p) => p.toJson()).toList(),
    };
  }
}

class ProdutoAgendamento {
  final int produtoId;
  final String nome;
  final double preco;
  final int quantidade;

  ProdutoAgendamento({
    required this.produtoId,
    required this.nome,
    required this.preco,
    this.quantidade = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'produto_id': produtoId,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
    };
  }
}
