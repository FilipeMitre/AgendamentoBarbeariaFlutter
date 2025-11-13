import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/transacao_model.dart';

class CarteiraBarbeiroScreen extends StatefulWidget {
  const CarteiraBarbeiroScreen({super.key});

  @override
  State<CarteiraBarbeiroScreen> createState() => _CarteiraBarbeiroScreenState();
}

class _CarteiraBarbeiroScreenState extends State<CarteiraBarbeiroScreen> {
  double _saldo = 0.0;
  List<TransacaoModel> _transacoes = [];
  bool _isLoading = true;
  Map<String, dynamic>? _estatisticas;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('DEBUG CARTEIRA: Carregando dados...');
    print('DEBUG CARTEIRA: User ID: ${authProvider.user?.id}');
    print('DEBUG CARTEIRA: Token exists: ${authProvider.token != null}');
    
    if (authProvider.user?.id == null || authProvider.token == null) {
      print('DEBUG CARTEIRA: User ID ou token nulo, retornando');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar saldo
      final saldoResponse = await ApiService.getSaldo(
        authProvider.user!.id!,
        authProvider.token!,
      );
      print('DEBUG CARTEIRA: Saldo response: $saldoResponse');

      // Carregar transações
      final transacoesResponse = await ApiService.getTransacoes(
        authProvider.user!.id!,
        authProvider.token!,
      );
      print('DEBUG CARTEIRA: Transações response: $transacoesResponse');

      // Carregar estatísticas
      final estatisticasResponse = await ApiService.getEstatisticasBarbeiro(
        authProvider.user!.id!,
        authProvider.token!,
      );
      print('DEBUG CARTEIRA: Estatísticas response: $estatisticasResponse');

      if (mounted) {
        setState(() {
          if (saldoResponse['success'] == true) {
            _saldo = double.tryParse(saldoResponse['saldo'].toString()) ?? 0.0;
            print('DEBUG CARTEIRA: Saldo definido: $_saldo');
          }

          if (transacoesResponse['success'] == true) {
            _transacoes = (transacoesResponse['transacoes'] as List)
                .map((json) => TransacaoModel.fromJson(json))
                .toList();
            print('DEBUG CARTEIRA: Transações carregadas: ${_transacoes.length}');
          }

          if (estatisticasResponse['success'] == true) {
            _estatisticas = estatisticasResponse['estatisticas'];
            print('DEBUG CARTEIRA: Estatísticas carregadas: $_estatisticas');
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG CARTEIRA: Erro: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Minha Carteira',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card do saldo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB84D), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saldo Disponível',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${_saldo.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                authProvider.user?.nome ?? 'Barbeiro',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Estatísticas
                    if (_estatisticas != null) ...[
                      const Text(
                        'Estatísticas do Mês',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Agendamentos',
                              '${_estatisticas!['agendamentos_concluidos'] ?? 0}',
                              Icons.calendar_today,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Receita Total',
                              'R\$ ${(double.tryParse(_estatisticas!['receita_total']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                              Icons.attach_money,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Histórico de transações
                    const Text(
                      'Histórico de Ganhos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_transacoes.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma transação ainda',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...(_transacoes.where((t) => 
                        t.tipo == 'recebimento' || 
                        t.tipo == 'comissao'
                      ).take(10).map((transacao) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTransacaoCard(transacao),
                        );
                      }).toList()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransacaoCard(TransacaoModel transacao) {
    final isRecebimento = transacao.tipo == 'recebimento';
    final color = isRecebimento ? Colors.green : const Color(0xFFFFB84D);
    final icon = isRecebimento ? Icons.trending_up : Icons.percent;

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.descricao ?? 'Transação',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(transacao.data),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ R\$ ${transacao.valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}