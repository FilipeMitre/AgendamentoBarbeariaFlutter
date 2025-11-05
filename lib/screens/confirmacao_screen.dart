import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'recomendacoes_screen.dart';
import '../navigation/main_navigation.dart';
import '../services/credit_service.dart';
import '../services/user_service.dart';

class ConfirmacaoScreen extends StatefulWidget {
  final String barber;
  final int day;
  final String time;
  final String package;

  const ConfirmacaoScreen({
    super.key,
    required this.barber,
    required this.day,
    required this.time,
    required this.package,
  });

  @override
  State<ConfirmacaoScreen> createState() => _ConfirmacaoScreenState();
}

class _ConfirmacaoScreenState extends State<ConfirmacaoScreen> {
  List<Map<String, dynamic>> selectedProducts = [];
  List<Map<String, dynamic>> selectedBebidas = [];
  double productsTotal = 0.0;
  double bebidasTotal = 0.0;
  double currentCredits = 0.0;
  int? userId;
  
  @override
  void initState() {
    super.initState();
    _loadCredits();
  }
  

  
  Future<void> _loadCredits() async {
    final id = await UserService.getUserId();
    final credits = await CreditService.getCredits(id);
    setState(() {
      userId = id;
      currentCredits = credits;
    });
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
          'Revise seu Agendamento',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Serviço
                    _buildInfoCard(
                      title: widget.package,
                      subtitle: _getServiceDescription(),
                      icon: Icons.content_cut,
                      onEdit: () {
                        Navigator.pop(context);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card Barbeiro
                    _buildInfoCard(
                      title: widget.barber,
                      subtitle: 'Barbeiro',
                      icon: Icons.person_outline,
                      onEdit: () {
                        Navigator.pop(context);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card Horário
                    _buildInfoCard(
                      title: widget.time,
                      subtitle: 'Segunda, 11 de Março',
                      icon: Icons.access_time,
                      onEdit: () {
                        Navigator.pop(context);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card Recomendações
                    _buildRecommendationCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // Card Saldo Atual
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seu Saldo Atual',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'R\$ ${currentCredits.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Resumo de valores
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow(widget.package, _getServicePrice()),
                          if (productsTotal > 0) ...[
                            const SizedBox(height: 12),
                            _buildPriceRow('Produtos', 'R\$ ${productsTotal.toStringAsFixed(2)}'),
                          ],
                          if (bebidasTotal > 0) ...[
                            const SizedBox(height: 12),
                            _buildPriceRow('Bebidas', 'R\$ ${bebidasTotal.toStringAsFixed(2)}'),
                          ],
                          const SizedBox(height: 16),
                          Divider(color: AppColors.inputBorder),
                          const SizedBox(height: 16),
                          _buildPriceRow(
                            'Total',
                            'R\$ ${(_getServicePriceValue() + productsTotal + bebidasTotal).toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Botão Agendar fixo
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final totalAmount = _getServicePriceValue() + productsTotal + bebidasTotal;
                  
                  // Buscar saldo atual diretamente
                  final credits = await CreditService.getCredits(userId);
                  print('DEBUG: Saldo atual: $credits, Valor necessário: $totalAmount');
                  
                  if (credits < totalAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saldo insuficiente! Você tem R\$ ${credits.toStringAsFixed(2)} e precisa de R\$ ${totalAmount.toStringAsFixed(2)}'),
                        backgroundColor: AppColors.error,
                        duration: Duration(seconds: 4),
                      ),
                    );
                    return;
                  }
                  
                  final success = await CreditService.debitCredits(totalAmount, userId);
                  
                  if (success) {
                    // Atualizar saldo na tela
                    await _loadCredits();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Agendamento confirmado! R\$ ${totalAmount.toStringAsFixed(2)} debitado.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigation()),
                        (route) => false,
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao processar pagamento. Tente novamente.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Text('Agendar corte'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.textSecondary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lightbulb_outline, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendações',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Adicione produtos e bebidas',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.textSecondary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecomendacoesScreen(
                    initialProducts: selectedProducts,
                    initialBebidas: selectedBebidas,
                    initialProductsTotal: productsTotal,
                    initialBebidasTotal: bebidasTotal,
                  ),
                ),
              );
              
              if (result != null) {
                setState(() {
                  selectedProducts = result['products'] ?? [];
                  selectedBebidas = result['bebidas'] ?? [];
                  productsTotal = result['productsTotal'] ?? 0.0;
                  bebidasTotal = result['bebidasTotal'] ?? 0.0;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  String _getServicePrice() {
    switch (widget.package) {
      case 'Corte de Cabelo':
        return 'R\$ 40,00';
      case 'Barba':
        return 'R\$ 20,00';
      case 'Completo':
        return 'R\$ 55,00';
      default:
        return 'R\$ 0,00';
    }
  }
  
  double _getServicePriceValue() {
    switch (widget.package) {
      case 'Corte de Cabelo':
        return 40.0;
      case 'Barba':
        return 20.0;
      case 'Completo':
        return 55.0;
      default:
        return 0.0;
    }
  }
  
  String _getServiceDescription() {
    switch (widget.package) {
      case 'Corte de Cabelo':
        return 'Corte de cabelo profissional';
      case 'Barba':
        return 'Aparar e modelar barba';
      case 'Completo':
        return 'Pacote com corte de cabelo e barba';
      default:
        return 'Serviço selecionado';
    }
  }
}