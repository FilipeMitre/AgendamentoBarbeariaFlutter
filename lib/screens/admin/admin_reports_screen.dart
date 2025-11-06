import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/admin_reports_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final AdminReportsService _reportsService = AdminReportsService();
  
  Map<String, dynamic> _reportsData = {};
  List<Map<String, dynamic>> _topBarbers = [];
  Map<String, dynamic> _comparisonData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    try {
      setState(() => _isLoading = true);
      
      final reportsData = await _reportsService.getReportsData();
      final topBarbers = await _reportsService.getTopBarbers();
      final comparisonData = await _reportsService.getComparisonData();
      
      setState(() {
        _reportsData = reportsData;
        _topBarbers = topBarbers;
        _comparisonData = comparisonData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar relatórios: $e')),
        );
      }
    }
  }

  String _getReceitaComparison() {
    final receitaAtual = _reportsData['receita_total'] ?? 0.0;
    final receitaAnterior = _comparisonData['receita_anterior'] ?? 0.0;
    
    if (receitaAnterior == 0) return 'Primeiro período';
    
    final percentual = ((receitaAtual - receitaAnterior) / receitaAnterior * 100);
    final sinal = percentual >= 0 ? '+' : '';
    return '${sinal}${percentual.toStringAsFixed(1)}% vs mês anterior';
  }

  String _getAgendamentosComparison() {
    final agendamentosAtual = _reportsData['total_agendamentos'] ?? 0;
    final agendamentosAnterior = _comparisonData['agendamentos_anterior'] ?? 0;
    
    final diferenca = agendamentosAtual - agendamentosAnterior;
    final sinal = diferenca >= 0 ? '+' : '';
    return '${sinal}$diferenca agendamentos';
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
          'Relatórios',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadReportsData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportsData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Período
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Período: Últimos 30 dias',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Receita Total
                    _buildReportCard(
                      'Receita Total',
                      'R\$ ${(_reportsData['receita_total'] ?? 0.0).toStringAsFixed(2)}',
                      Icons.attach_money,
                      AppColors.success,
                      _getReceitaComparison(),
                    ),

                    SizedBox(height: 16),

                    // Agendamentos
                    _buildReportCard(
                      'Total de Agendamentos',
                      '${_reportsData['total_agendamentos'] ?? 0}',
                      Icons.calendar_month,
                      AppColors.primary,
                      _getAgendamentosComparison(),
                    ),

                    SizedBox(height: 16),

                    // Taxa de cancelamento
                    _buildReportCard(
                      'Taxa de Cancelamento',
                      '${(_reportsData['taxa_cancelamento'] ?? 0.0).toStringAsFixed(1)}%',
                      Icons.cancel_outlined,
                      AppColors.error,
                      'Últimos 30 dias',
                    ),

                    SizedBox(height: 16),

                    // Produtos vendidos
                    _buildReportCard(
                      'Produtos Vendidos',
                      '${_reportsData['quantidade_produtos'] ?? 0}',
                      Icons.shopping_bag,
                      AppColors.secondary,
                      'R\$ ${(_reportsData['vendas_produtos'] ?? 0.0).toStringAsFixed(2)} em vendas',
                    ),

                    SizedBox(height: 24),

                    // Top Barbeiros
                    Text(
                      'Top Barbeiros',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16),

                    if (_topBarbers.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Nenhum dado de barbeiro encontrado',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._topBarbers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final barber = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < _topBarbers.length - 1 ? 12 : 0),
                          child: _buildTopBarberCard(
                            barber['barbeiro_nome'] ?? 'Barbeiro',
                            'R\$ ${(barber['receita_total'] ?? 0.0).toStringAsFixed(2)}',
                            barber['total_atendimentos'] ?? 0,
                            index + 1,
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReportCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarberCard(String nome, String receita, int atendimentos, int posicao) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: posicao == 1
                  ? AppColors.primary
                  : posicao == 2
                      ? AppColors.secondary
                      : AppColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$posicao',
                style: TextStyle(
                  color: posicao <= 2 ? Colors.white : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$atendimentos atendimentos',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            receita,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}