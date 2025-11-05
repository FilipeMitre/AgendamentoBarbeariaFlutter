import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/credit_service.dart';
import '../services/user_service.dart';

class RecargaScreen extends StatefulWidget {
  final double saldoAtual;

  const RecargaScreen({
    super.key,
    required this.saldoAtual,
  });

  @override
  State<RecargaScreen> createState() => _RecargaScreenState();
}

class _RecargaScreenState extends State<RecargaScreen> {
  String metodoPagamento = 'Pix';
  final TextEditingController _valorController = TextEditingController();

  final List<String> metodos = ['Pix', 'Cartão de Crédito', 'Cartão de Débito'];

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  void _processarRecarga() async {
    if (_valorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite um valor para recarregar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite um valor válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Processando recarga...',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Adicionar créditos no banco de dados
      final userId = await UserService.getUserId();
      print('=== RECARGA DEBUG ===');
      print('UserID: $userId');
      print('Valor a adicionar: $valor');
      
      await CreditService.addCredits(valor, userId);
      
      // Buscar novo saldo
      final novoSaldo = await CreditService.getCredits(userId);
      print('Novo saldo após recarga: $novoSaldo');
      print('====================');
      
      Navigator.pop(context); // Fecha o loading
      Navigator.pop(context, novoSaldo); // Retorna novo saldo

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recarga de R\$ ${valor.toStringAsFixed(2)} realizada com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar recarga. Tente novamente.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'minha carteira',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Fala, Vinícius',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.waving_hand, color: AppColors.primary, size: 20),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Salvador-BA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 32),

              // Card de Recarga
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Faça a sua Recarga',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Método de pagamento
                    Text(
                      'Método de pagamento',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Dropdown de métodos
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: DropdownButton<String>(
                        value: metodoPagamento,
                        isExpanded: true,
                        underline: SizedBox(),
                        dropdownColor: AppColors.cardBackground,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        icon: Icon(Icons.check, color: AppColors.primary),
                        items: metodos.map((String metodo) {
                          return DropdownMenuItem<String>(
                            value: metodo,
                            child: Text(metodo),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            metodoPagamento = newValue!;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // Valor da recarga
                    Text(
                      'Valor da recarga',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: _valorController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Digite o valor',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        prefixText: 'R\$ ',
                        prefixStyle: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Botão Depositar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _processarRecarga,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Depositar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}