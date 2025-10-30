import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'produtos_screen.dart';

class ConfirmacaoScreen extends StatelessWidget {
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
                    // Card Completo
                    _buildInfoCard(
                      title: 'Completo',
                      subtitle: 'Pacote com corte de cabelo e barba',
                      icon: Icons.person,
                      onEdit: () {
                        Navigator.pop(context);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card Barbeiro
                    _buildInfoCard(
                      title: barber,
                      subtitle: 'Barbeiro',
                      icon: Icons.person_outline,
                      onEdit: () {
                        Navigator.pop(context);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Card Horário
                    _buildInfoCard(
                      title: time,
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
                    
                    // Resumo de valores
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Cabelo', 'R\$ 40,00'),
                          const SizedBox(height: 12),
                          _buildPriceRow('Barba', 'R\$ 20,00'),
                          const SizedBox(height: 12),
                          _buildPriceRow('Bebidas', 'R\$ 22,98'),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.inputBorder),
                          const SizedBox(height: 16),
                          _buildPriceRow(
                            'Total',
                            'R\$ 82,98',
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
                onPressed: () {
                  // TODO: Confirmar agendamento
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agendamento confirmado!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProdutosScreen(),
                ),
              );
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
}