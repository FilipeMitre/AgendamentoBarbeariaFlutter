import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final _taxaComissaoController = TextEditingController(text: '5');
  final _prazoCancelamentoController = TextEditingController(text: '2');
  final _taxaCancelamentoController = TextEditingController(text: '10');
  final _intervaloAgendamentoController = TextEditingController(text: '30');

  bool _isLoading = false;

  @override
  void dispose() {
    _taxaComissaoController.dispose();
    _prazoCancelamentoController.dispose();
    _taxaCancelamentoController.dispose();
    _intervaloAgendamentoController.dispose();
    super.dispose();
  }

  Future<void> _salvarConfiguracoes() async {
    setState(() {
      _isLoading = true;
    });

    // Simular salvamento
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Configurações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configurações Financeiras
            const Text(
              'Configurações Financeiras',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            _buildConfigField(
              'Taxa de Comissão (%)',
              'Porcentagem cobrada sobre cada serviço',
              _taxaComissaoController,
              TextInputType.number,
            ),

            const SizedBox(height: 16),

            _buildConfigField(
              'Taxa de Cancelamento Tardio (%)',
              'Porcentagem cobrada em cancelamentos tardios',
              _taxaCancelamentoController,
              TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Configurações de Agendamento
            const Text(
              'Configurações de Agendamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            _buildConfigField(
              'Prazo Mínimo para Cancelamento (horas)',
              'Tempo mínimo antes do agendamento para cancelar sem taxa',
              _prazoCancelamentoController,
              TextInputType.number,
            ),

            const SizedBox(height: 16),

            _buildConfigField(
              'Intervalo entre Agendamentos (minutos)',
              'Tempo padrão entre cada agendamento',
              _intervaloAgendamentoController,
              TextInputType.number,
            ),

            const SizedBox(height: 32),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _salvarConfiguracoes,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text('Salvar Configurações'),
              ),
            ),

            const SizedBox(height: 24),

            // Informações do Sistema
            const Text(
              'Informações do Sistema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Versão', '1.0.0'),
                  const Divider(color: Color(0xFF333333), height: 24),
                  _buildInfoRow('Banco de Dados', 'MySQL 8.0'),
                  const Divider(color: Color(0xFF333333), height: 24),
                  _buildInfoRow('API', 'Node.js'),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigField(
    String label,
    String hint,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF333333)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF333333)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFFB84D)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
          value,
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
