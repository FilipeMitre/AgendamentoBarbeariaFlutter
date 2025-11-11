import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/barbeiro_model.dart';
import '../providers/auth_provider.dart';
import 'recomendacoes_screen.dart';

class ConfirmarAgendamentoScreen extends StatefulWidget {
  final BarbeiroModel barbeiro;
  final String barbeiroNome;
  final DateTime data;
  final String horario;
  final String pacote;

  const ConfirmarAgendamentoScreen({
    super.key,
    required this.barbeiro,
    required this.barbeiroNome,
    required this.data,
    required this.horario,
    required this.pacote,
  });

  @override
  State<ConfirmarAgendamentoScreen> createState() =>
      _ConfirmarAgendamentoScreenState();
}

class _ConfirmarAgendamentoScreenState
    extends State<ConfirmarAgendamentoScreen> {
  bool _isLoading = false;

  // Valores mockados - virão do banco
  final double _valorCabelo = 40.00;
  final double _valorBarba = 20.00;
  final double _valorBebidas = 22.98;

  double get _valorTotal {
    if (widget.pacote == 'Completo') {
      return _valorCabelo + _valorBarba + _valorBebidas;
    }
    return _valorCabelo + _valorBebidas;
  }

  Future<void> _confirmarAgendamento() async {
    setState(() {
      _isLoading = true;
    });

    // Simular chamada API
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navegar para recomendações
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RecomendacoesScreen(),
        ),
      );
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
              // Card Completo
              _buildInfoCard(
                icon: Icons.check_circle,
                color: const Color(0xFFFFB84D),
                title: widget.pacote,
                subtitle: widget.pacote == 'Completo'
                    ? 'Pacote com corte de cabelo e barba'
                    : 'Apenas corte de cabelo',
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
                    _buildValorRow('Cabelo', _valorCabelo),
                    if (widget.pacote == 'Completo') ...[
                      const SizedBox(height: 12),
                      _buildValorRow('Barba', _valorBarba),
                    ],
                    const SizedBox(height: 12),
                    _buildValorRow('Bebidas', _valorBebidas),
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
            icon: const Icon(Icons.edit, color: Color(0xFFFFB84D), size: 20),
            onPressed: () {
              // Voltar para editar
              Navigator.pop(context);
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
}
