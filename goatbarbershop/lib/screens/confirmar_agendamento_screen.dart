import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/barbeiro_model.dart';
import '../models/servico_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../providers/agendamento_provider.dart';
import 'recomendacoes_screen.dart';
import 'produtos_screen.dart';
import 'bebidas_screen.dart';

class ConfirmarAgendamentoScreen extends StatefulWidget {
  final BarbeiroModel barbeiro;
  final String barbeiroNome;
  final DateTime data;
  final String horario;
  final ServicoModel servico;

  const ConfirmarAgendamentoScreen({
    super.key,
    required this.barbeiro,
    required this.barbeiroNome,
    required this.data,
    required this.horario,
    required this.servico,
  });

  @override
  State<ConfirmarAgendamentoScreen> createState() =>
      _ConfirmarAgendamentoScreenState();
}

class _ConfirmarAgendamentoScreenState
    extends State<ConfirmarAgendamentoScreen> {
  bool _isLoading = false;
  Map<String, double> _produtosSelecionados = {}; // nome: valor

  double get _valorProdutos {
    return _produtosSelecionados.values.fold(0.0, (sum, valor) => sum + valor);
  }

  double get _valorTotal {
    return widget.servico.preco + _valorProdutos;
  }

  Future<void> _confirmarAgendamento() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user?.id == null || authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${authProvider.user?.id == null ? 'Usuário' : 'Token'} não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('DEBUG: User ID: ${authProvider.user!.id}');
    print('DEBUG: Token exists: ${authProvider.token != null}');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.criarAgendamento(
        clienteId: authProvider.user!.id!,
        barbeiroId: widget.barbeiro.id, // ID do barbeiro selecionado
        servicoId: widget.servico.id,
        dataAgendamento: DateFormat('yyyy-MM-dd').format(widget.data),
        horario: widget.horario,
        token: authProvider.token!,
        produtos: _produtosSelecionados.isNotEmpty ? _produtosSelecionados : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['success'] == true) {
          // Recarregar agendamentos
          final agendamentoProvider = Provider.of<AgendamentoProvider>(context, listen: false);
          await agendamentoProvider.carregarAgendamentosAtivos(
            authProvider.user!.id!, 
            authProvider.token!
          );
          
          // Voltar para home com mensagem de sucesso
          Navigator.popUntil(context, (route) => route.isFirst);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agendamento realizado com sucesso!'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Erro ao criar agendamento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro de conexão com o servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataFormatada = DateFormat('EEEE, d \'de\' MMMM', 'pt_BR')
        .format(widget.data);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Revise seu Agendamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Serviço
              _buildInfoCard(
                icon: _getServiceIcon(widget.servico.nome),
                color: const Color(0xFFFFB84D),
                title: widget.servico.nome,
                subtitle: widget.servico.descricao ?? 'Serviço de barbearia',
              ),

              const SizedBox(height: 12),

              // Card Barbeiro
              _buildInfoCard(
                icon: Icons.person,
                color: Colors.blue,
                title: widget.barbeiroNome,
                subtitle: 'Barbeiro',
              ),

              const SizedBox(height: 12),

              // Card Data/Hora
              _buildInfoCard(
                icon: Icons.access_time,
                color: Colors.orange,
                title: '${widget.horario}',
                subtitle: dataFormatada,
              ),

              const SizedBox(height: 12),

              // Card Recomendações
              _buildInfoCard(
                icon: Icons.star,
                color: Colors.purple,
                title: 'Recomendações',
                subtitle: 'Adicione produtos e bebidas',
                isRecommendation: true,
              ),

              const SizedBox(height: 32),

              // Resumo de valores
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Column(
                  children: [
                    _buildValorRow(widget.servico.nome, widget.servico.preco),
                    // Mostrar produtos selecionados
                    if (_produtosSelecionados.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._produtosSelecionados.entries.map((entry) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildValorRow(entry.key, entry.value),
                        ),
                      ).toList(),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Color(0xFF333333), height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'R\$ ${_valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFB84D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão Agendar corte
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarAgendamento,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text('Agendar corte'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool isRecommendation = false,
  }) {
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
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isRecommendation ? Icons.add_shopping_cart : Icons.edit,
              color: const Color(0xFFFFB84D),
              size: 20,
            ),
            onPressed: () {
              if (isRecommendation) {
                // Navegar para tela de produtos
                _showProductSelection();
              } else {
                // Voltar para editar agendamento
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValorRow(String label, double valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          'R\$ ${valor.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showProductSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Adicionar ao agendamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.shopping_bag,
                    title: 'Produtos',
                    subtitle: 'Cremes, géis e acessórios',
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProdutosScreen(),
                        ),
                      );
                      
                      if (result != null && result is Map<String, double>) {
                        setState(() {
                          _produtosSelecionados.addAll(result);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.local_bar,
                    title: 'Bebidas',
                    subtitle: 'Cervejas e refrigerantes',
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BebidasScreen(),
                        ),
                      );
                      
                      if (result != null && result is Map<String, double>) {
                        setState(() {
                          _produtosSelecionados.addAll(result);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB84D).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFB84D),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('completo') || name.contains('corte + barba')) {
      return Icons.check_circle;
    } else if (name.contains('barba')) {
      return Icons.face;
    } else if (name.contains('corte') || name.contains('cabelo')) {
      return Icons.content_cut;
    } else if (name.contains('coloração') || name.contains('tintura')) {
      return Icons.palette;
    } else if (name.contains('hidratação') || name.contains('tratamento')) {
      return Icons.water_drop;
    } else if (name.contains('escova')) {
      return Icons.brush;
    } else if (name.contains('luzes') || name.contains('mechas')) {
      return Icons.highlight;
    } else {
      return Icons.content_cut;
    }
  }
}
