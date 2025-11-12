import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/carteira_provider.dart';
import '../models/transacao_model.dart';

class HistoricoTransacoesScreen extends StatefulWidget {
  const HistoricoTransacoesScreen({super.key});

  @override
  State<HistoricoTransacoesScreen> createState() =>
      _HistoricoTransacoesScreenState();
}

class _HistoricoTransacoesScreenState extends State<HistoricoTransacoesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<CarteiraProvider>(context, listen: false)
            .carregarTransacoes(authProvider.user!.id!, authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final carteiraProvider = Provider.of<CarteiraProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico de Transações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: carteiraProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
              ),
            )
          : carteiraProvider.transacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma transação encontrada',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: carteiraProvider.transacoes.length,
                  itemBuilder: (context, index) {
                    final transacao = carteiraProvider.transacoes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTransacaoCard(transacao),
                    );
                  },
                ),
    );
  }

  Widget _buildTransacaoCard(TransacaoModel transacao) {
    final isCredito = transacao.isCredito;
    final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(transacao.data);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCredito
                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredito ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredito ? const Color(0xFF4CAF50) : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.tipoFormatado,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (transacao.descricao != null)
                  Text(
                    transacao.descricao!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  dataFormatada,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredito ? '+' : '-'} R\$ ${transacao.valor.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCredito ? const Color(0xFF4CAF50) : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saldo: R\$ ${transacao.saldoPosterior.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
