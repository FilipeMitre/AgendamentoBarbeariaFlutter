import 'package:flutter/material.dart';
import '../services/barber_dashboard_service.dart';

import '../theme/app_colors.dart';
import '../services/token_manager.dart';

class BarberScreen extends StatefulWidget {
  const BarberScreen({super.key});

  @override
  State<BarberScreen> createState() => _BarberScreenState();
}

class _BarberScreenState extends State<BarberScreen> with TickerProviderStateMixin {
  final BarberDashboardService _barberService = BarberDashboardService();

  late TabController _tabController;
  
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Pegar ID do usuário logado
      final userData = await TokenManager.getUserData();
      _currentUserId = userData?['id'];
      
      if (_currentUserId != null) {
        final appointments = await _barberService.getBarberAppointments(_currentUserId!);
        final clients = await _barberService.getClients();
        final services = <Map<String, dynamic>>[
          {'id': 1, 'name': 'Corte Clássico', 'duration': 45},
          {'id': 2, 'name': 'Barba Completa', 'duration': 30},
          {'id': 3, 'name': 'Corte + Barba', 'duration': 75},
        ];
        
        setState(() {
          _appointments = appointments;
          _clients = clients;
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final success = await _barberService.updateAppointmentStatus(appointmentId, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status atualizado!')),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _showCreateAppointmentDialog() {
    int? selectedClientId;
    int? selectedServiceId;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Agendamento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  value: selectedClientId,
                  items: _clients.map((client) => DropdownMenuItem<int>(
                    value: client['id'],
                    child: Text(client['name']),
                  )).toList(),
                  onChanged: (value) => setDialogState(() => selectedClientId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Serviço'),
                  value: selectedServiceId,
                  items: _services.map((service) => DropdownMenuItem<int>(
                    value: service['id'],
                    child: Text('${service['name']} - ${service['duration']}min'),
                  )).toList(),
                  onChanged: (value) => setDialogState(() => selectedServiceId = value),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Horário'),
                  subtitle: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedClientId != null && selectedServiceId != null
                  ? () async {
                      try {
                        final dateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        
                        final success = await _barberService.createAppointment(
                          clientId: selectedClientId!,
                          barberId: _currentUserId!,
                          serviceId: selectedServiceId!,
                          dateTime: dateTime.toIso8601String(),
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                        
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Agendamento criado!')),
                          );
                          _loadData();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: $e')),
                        );
                      }
                    }
                  : null,
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel do Barbeiro'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Meus Agendamentos'),
            Tab(text: 'Novo Agendamento'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(),
                _buildNewAppointmentTab(),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_appointments.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum agendamento encontrado',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          final dateTimeStr = appointment['data_hora_agendamento'];
          
          // Parse manual sem conversão de timezone
          String formattedDateTime = '';
          try {
            final parts = dateTimeStr.split(' ');
            if (parts.length >= 2) {
              final dateParts = parts[0].split('-');
              final timeParts = parts[1].split(':');
              if (dateParts.length == 3 && timeParts.length >= 2) {
                final day = dateParts[2];
                final month = dateParts[1];
                final year = dateParts[0];
                final hour = timeParts[0].padLeft(2, '0');
                final minute = timeParts[1].padLeft(2, '0');
                formattedDateTime = '$day/$month/$year às $hour:$minute';
              }
            }
          } catch (e) {
            formattedDateTime = dateTimeStr;
          }
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: AppColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appointment['cliente_nome'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(appointment['status']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appointment['servico_nome'],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDateTime,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (appointment['observacoes'] != null && appointment['observacoes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Obs: ${appointment['observacoes']}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (appointment['status'] == 'confirmado') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateAppointmentStatus(appointment['id'], 'concluido'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Concluir'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateAppointmentStatus(appointment['id'], 'cancelado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewAppointmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: AppColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Criar Novo Agendamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agende um horário para seus clientes',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showCreateAppointmentDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Novo Agendamento'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return Colors.blue;
      case 'concluido':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmado':
        return 'Confirmado';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }
}