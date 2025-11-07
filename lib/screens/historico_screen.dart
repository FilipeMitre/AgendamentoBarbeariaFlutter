import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/appointment_history_service.dart';
import '../services/user_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentHistoryService _appointmentService = AppointmentHistoryService();
  
  List<Map<String, dynamic>> agendamentosAtivos = [];
  List<Map<String, dynamic>> agendamentosFinalizados = [];
  List<Map<String, dynamic>> agendamentosCancelados = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }
  
  Future<void> _loadAppointments() async {
    try {
      final userId = await UserService.getUserId();
      if (userId == null) return;
      
      setState(() {
        _userId = userId;
        _isLoading = true;
      });
      
      final appointments = await _appointmentService.getAllUserAppointments(userId);
      
      setState(() {
        agendamentosAtivos = appointments['confirmado'] ?? [];
        agendamentosFinalizados = appointments['concluido'] ?? [];
        agendamentosCancelados = appointments['cancelado'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
      );
    }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
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
                'R\$ ${double.parse(agendamento['preco_creditos'].toString()).toStringAsFixed(2)}',
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
          _buildInfoRow(Icons.store, 'GOATbarber'),
          SizedBox(height: 12),
          _buildInfoRow(Icons.content_cut, agendamento['servico_nome']),
          SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, agendamento['barbeiro_nome']),
          SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, _formatDate(agendamento['data_hora_agendamento'])),
          SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, _formatTime(agendamento['data_hora_agendamento'])),

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

  String _formatDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      return '${dateTime.day} de ${months[dateTime.month - 1]}, ${dateTime.year}';
    } catch (e) {
      return dateTimeStr;
    }
  }
  
  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
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
            'Tem certeza que deseja cancelar este agendamento?\n\nServiço: ${agendamento['servico_nome']}\nData: ${_formatDate(agendamento['data_hora_agendamento'])}\nHorário: ${_formatTime(agendamento['data_hora_agendamento'])}',
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
              onPressed: () async {
                Navigator.pop(context);
                
                try {
                  final success = await _appointmentService.cancelAppointment(agendamento['id']);
                  
                  if (success) {
                    await _loadAppointments(); // Recarregar dados
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Agendamento cancelado com sucesso'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao cancelar agendamento'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao cancelar agendamento: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
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
