import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/carteira_provider.dart';

class RecarregarCarteiraScreen extends StatefulWidget {
  const RecarregarCarteiraScreen({super.key});

  @override
  State<RecarregarCarteiraScreen> createState() =>
      _RecarregarCarteiraScreenState();
}

class _RecarregarCarteiraScreenState extends State<RecarregarCarteiraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  String _metodoPagamento = 'Pix';
  bool _isLoading = false;

  final List<String> _metodosPagamento = [
    'Pix',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Boleto',
  ];

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _realizarRecarga() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final carteiraProvider = Provider.of<CarteiraProvider>(context, listen: false);

      // Remover formatação e converter para double
      final valorTexto = _valorController.text.replaceAll('R\$ ', '').replaceAll(',', '.');
      final valor = double.tryParse(valorTexto) ?? 0;

      if (authProvider.user != null && authProvider.token != null) {
        final sucesso = await carteiraProvider.recarregar(
          authProvider.user!.id!,
          valor,
          authProvider.token!,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (sucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recarga realizada com sucesso!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(carteiraProvider.errorMessage ?? 'Erro ao realizar recarga'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fala, ${user?.nome.split(' ').first ?? 'Usuário'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color(0xFFFFB84D),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Salvador-BA',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF333333)),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFFFFB84D),
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Card de Recarga
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Faça a sua Recarga',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Método de pagamento
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metodo de pagamento',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF333333)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _metodoPagamento,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF2A2A2A),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  items: _metodosPagamento.map((String metodo) {
                                    return DropdownMenuItem<String>(
                                      value: metodo,
                                      child: Text(metodo),
                                    );
                                  }).toList(),
                                  onChanged: (String? novoMetodo) {
                                    if (novoMetodo != null) {
                                      setState(() {
                                        _metodoPagamento = novoMetodo;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Valor do depósito
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valor do depósito',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _valorController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                              ],
                              decoration: InputDecoration(
                                hintText: 'R\$ 0,00',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF333333)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF333333)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFFFB84D)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite o valor da recarga';
                                }
                                final valorTexto = value.replaceAll('R\$ ', '').replaceAll(',', '.');
                                final valor = double.tryParse(valorTexto);
                                if (valor == null || valor <= 0) {
                                  return 'Digite um valor válido';
                                }
                                if (valor < 10) {
                                  return 'Valor mínimo: R\$ 10,00';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        const Divider(color: Color(0xFF333333), height: 1),

                        const SizedBox(height: 24),

                        // Botão Depositar
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _realizarRecarga,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text('Depositar'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informações adicionais
                  Container(
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
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFFFB84D),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Informações importantes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Valor mínimo de recarga: R\$ 10,00\n'
                          '• Os créditos são adicionados instantaneamente\n'
                          '• Utilize os créditos para agendar serviços\n'
                          '• Não é possível sacar os créditos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
