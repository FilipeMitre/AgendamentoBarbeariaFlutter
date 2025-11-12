import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/agendamento_model.dart';
import '../services/api_service.dart';

class MeusAgendamentosScreen extends StatefulWidget {
  const MeusAgendamentosScreen({super.key});

  @override
  State<MeusAgendamentosScreen> createState() => _MeusAgendamentosScreenState();
}

class _MeusAgendamentosScreenState extends State<MeusAgendamentosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<AgendamentoModel> _agendamentosAtivos = [];
  List<AgendamentoModel> _agendamentosHistorico = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user?.id == null || authProvider.token == null) return;

    try {
      final [ativosResponse, historicoResponse] = await Future.wait([
        ApiService.getAgendamentosAtivos(authProvider.user!.id!, authProvider.token!),
        ApiService.getHistoricoAgendamentos(authProvider.user!.id!, authProvider.token!),
      ]);

      if (mounted) {
        setState(() {
          if (ativosResponse['success'] == true && ativosResponse['agendamentos'] != null) {
            _agendamentosAtivos = (ativosResponse['agendamentos'] as List)
                .map((json) => AgendamentoModel.fromJson(json))
                .toList();
          }
          
          if (historicoResponse['success'] == true && historicoResponse['agendamentos'] != null) {
            _agendamentosHistorico = (historicoResponse['agendamentos'] as List)
                .map((json) => AgendamentoModel.fromJson(json))
                .toList();
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meus Agendamentos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFB84D),
          labelColor: const Color(0xFFFFB84D),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Ativos'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAgendamentosAtivos(),
          _buildHistoricoAgendamentos(),
        ],
      ),
    );
  }

  Widget _buildAgendamentosAtivos() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
        ),
      );
    }

    if (_agendamentosAtivos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'Nenhum agendamento ativo',
        subtitle: 'Você não possui agendamentos confirmados no momento.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _agendamentosAtivos.length,
      itemBuilder: (context, index) {
        final agendamento = _agendamentosAtivos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildAgendamentoCard(agendamento, isActive: true),
        );
      },
    );
  }

  Widget _buildHistoricoAgendamentos() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
        ),
      );
    }

    if (_agendamentosHistorico.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Nenhum histórico',
        subtitle: 'Você ainda não possui agendamentos anteriores.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _agendamentosHistorico.length,
      itemBuilder: (context, index) {
        final agendamento = _agendamentosHistorico[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildAgendamentoCard(agendamento, isActive: false),
        );
      },
    );
  }

  Widget _buildAgendamentoCard(AgendamentoModel agendamento, {required bool isActive}) {
    final dataFormatada = DateFormat('dd/MM/yyyy').format(agendamento.dataAgendamento);
    final diaSemana = DateFormat('EEEE', 'pt_BR').format(agendamento.dataAgendamento);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFFFB84D) : const Color(0xFF333333),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                agendamento.servicoNome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(agendamento.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(agendamento.status)),
                ),
                child: Text(
                  _getStatusText(agendamento.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(agendamento.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                agendamento.barbeiroNome,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '$diaSemana, $dataFormatada',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                agendamento.horario,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ ${agendamento.valorServico.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFB84D),
                ),
              ),
              if (isActive && agendamento.status == 'confirmado')
                TextButton(
                  onPressed: () => _showCancelDialog(agendamento),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return const Color(0xFF4CAF50);
      case 'concluido':
        return const Color(0xFF2196F3);
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
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

  void _showCancelDialog(AgendamentoModel agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Cancelar Agendamento',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Não',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar cancelamento
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agendamento cancelado com sucesso!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
  }
}