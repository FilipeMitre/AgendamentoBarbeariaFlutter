class TransacaoModel {
  final int id;
  final String tipo;
  final double valor;
  final double saldoAnterior;
  final double saldoPosterior;
  final String? descricao;
  final DateTime data;

  TransacaoModel({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.saldoAnterior,
    required this.saldoPosterior,
    this.descricao,
    required this.data,
  });

  factory TransacaoModel.fromJson(Map<String, dynamic> json) {
    return TransacaoModel(
      id: json['id'],
      tipo: json['tipo_transacao'],
      valor: double.tryParse(json['valor']?.toString() ?? '0') ?? 0.0,
      saldoAnterior: double.tryParse(json['saldo_anterior']?.toString() ?? '0') ?? 0.0,
      saldoPosterior: double.tryParse(json['saldo_posterior']?.toString() ?? '0') ?? 0.0,
      descricao: json['descricao'],
      data: DateTime.parse(json['data_transacao']),
    );
  }

  String get tipoFormatado {
    switch (tipo) {
      case 'recarga':
        return 'Recarga';
      case 'pagamento':
        return 'Pagamento';
      case 'recebimento':
        return 'Recebimento';
      case 'estorno':
        return 'Estorno';
      case 'taxa_cancelamento':
        return 'Taxa de Cancelamento';
      case 'comissao':
        return 'Comissão';
      default:
        return tipo;
    }
  }

  bool get isCredito {
    return tipo == 'recarga' || tipo == 'recebimento' || tipo == 'estorno';
  }
}
