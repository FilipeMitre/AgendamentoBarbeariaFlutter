import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> agendamentosAtivos = [
    {
      'id': '001',
      'servico': 'Completo',
      'barbeiro': 'Vinicius Brabo',
      'data': '11 de Março, 2024',
      'horario': '14:30',
      'preco': 55.00,
      'status': 'confirmado',
      'barbearia': 'GOATbarber',
    },
    {
      'id': '002',
      'servico': 'Corte de Cabelo',
      'barbeiro': 'Carlos Silva',
      'data': '15 de Março, 2024',
      'horario': '16:00',
      'preco': 40.00,
      'status': 'confirmado',
      'barbearia': 'GOATbarber',
    },
  ];

  final List<Map<String, dynamic>> agendamentosFinalizados = [
    {
      'id': '003',
      'servico': 'Barba',
      'barbeiro': 'João Pedro',
      'data': '05 de Março, 2024',
      'horario': '10:00',
      'preco': 20.00,
      'status': 'concluido',
      'barbearia': 'GOATbarber',
    },
    {
      'id': '004',
      'servico': 'Completo',
      'barbeiro': 'Vinicius Brabo',
      'data': '28 de Fevereiro, 2024',
      'horario': '15:00',
      'preco': 55.00,
      'status': 'concluido',
      'barbearia': 'GOATbarber',
    },
    {
      'id': '005',
      'servico': 'Corte de Cabelo',
      'barbeiro': 'Carlos Silva',
      'data': '20 de Fevereiro, 2024',
      'horario': '11:30',
      'preco': 40.00,
      'status': 'concluido',
      'barbearia': 'GOATbarber',
    },
  ];

  final List<Map<String, dynamic>> agendamentosCancelados = [
    {
      'id': '006',
      'servico': 'Completo',
      'barbeiro': 'João Pedro',
      'data': '18 de Fevereiro, 2024',
      'horario': '14:00',
      'preco': 55.00,
      'status': 'cancelado',
      'barbearia': 'GOATbarber',
      'motivoCancelamento': 'Cancelado pelo cliente',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Meus Agendamentos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Ativos (${agendamentosAtivos.length})'),
            Tab(text: 'Finalizados'),
            Tab(text: 'Cancelados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAgendamentosList(agendamentosAtivos, 'ativos'),
          _buildAgendamentosList(agendamentosFinalizados, 'finalizados'),
          _buildAgendamentosList(agendamentosCancelados, 'cancelados'),
        ],
      ),
    );
  }

  Widget _buildAgendamentosList(
    List<Map<String, dynamic>> agendamentos,
    String tipo,
  ) {
    if (agendamentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum agendamento $tipo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(24),
      itemCount: agendamentos.length,
      itemBuilder: (context, index) {
        return _buildAgendamentoCard(agendamentos[index], tipo);
      },
    );
  }

  Widget _buildAgendamentoCard(Map<String, dynamic> agendamento, String tipo) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(agendamento['status']),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(agendamento['status']),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '#${agendamento['id']}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                'R\$ ${agendamento['preco'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          Divider(color: AppColors.inputBorder, height: 1),
          SizedBox(height: 16),

          // Informações do agendamento
          _buildInfoRow(Icons.store, agendamento['barbearia']),
          SizedBox(height: 12),
          _buildInfoRow(Icons.content_cut, agendamento['servico']),
          SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, agendamento['barbeiro']),
          SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, agendamento['data']),
          SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, agendamento['horario']),

          // Motivo de cancelamento (se aplicável)
          if (agendamento['motivoCancelamento'] != null) ...[
            SizedBox(height: 12),
            _buildInfoRow(
              Icons.info_outline,
              agendamento['motivoCancelamento'],
              isWarning: true,
            ),
          ],

          // Ações
          if (tipo == 'ativos') ...[
            SizedBox(height: 16),
            Divider(color: AppColors.inputBorder, height: 1),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(agendamento);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Reagendar
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Reagendar'),
                  ),
                ),
              ],
            ),
          ],

          if (tipo == 'finalizados') ...[
            SizedBox(height: 16),
            Divider(color: AppColors.inputBorder, height: 1),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Agendar novamente
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Agendar Novamente'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: isWarning ? AppColors.warning : AppColors.textSecondary,
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isWarning ? AppColors.warning : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return AppColors.success;
      case 'concluido':
        return AppColors.secondary;
      case 'cancelado':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmado':
        return 'CONFIRMADO';
      case 'concluido':
        return 'CONCLUÍDO';
      case 'cancelado':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  void _showCancelDialog(Map<String, dynamic> agendamento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancelar agendamento',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Tem certeza que deseja cancelar este agendamento?\n\nServiço: ${agendamento['servico']}\nData: ${agendamento['data']}\nHorário: ${agendamento['horario']}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Voltar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  agendamento['status'] = 'cancelado';
                  agendamento['motivoCancelamento'] = 'Cancelado pelo cliente';
                  
                  // Move para lista de cancelados
                  agendamentosAtivos.removeWhere((a) => a['id'] == agendamento['id']);
                  agendamentosCancelados.add(agendamento);
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Agendamento cancelado com sucesso'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text('Confirmar cancelamento'),
            ),
          ],
        );
      },
    );
  }
}
