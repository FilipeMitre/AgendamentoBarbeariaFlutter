import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/agendamento_model.dart';
import '../../services/api_service.dart';
import 'cronograma_dia_screen.dart';
import 'carteira_barbeiro_screen.dart';

class BarberDashboardScreen extends StatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  State<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  List<AgendamentoModel> _agendamentosHoje = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentosHoje();
  }

  Future<void> _carregarAgendamentosHoje() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('DEBUG: Carregando agendamentos...');
    print('DEBUG: User ID: ${authProvider.user?.id}');
    print('DEBUG: Token exists: ${authProvider.token != null}');
    
    if (authProvider.user?.id == null || authProvider.token == null) {
      print('DEBUG: User ID ou token nulo, retornando');
      return;
    }

    try {
      final response = await ApiService.getTodosAgendamentosBarbeiro(
        authProvider.user!.id!,
        authProvider.token!,
      );

      print('DEBUG: Response: $response');

      if (response['success'] == true && mounted) {
        final todosAgendamentos = (response['agendamentos'] as List)
            .map((json) => AgendamentoModel.fromJson(json))
            .toList();
        
        // Filtrar apenas agendamentos de hoje
        final hoje = DateTime.now();
        final agendamentosHoje = todosAgendamentos.where((agendamento) {
          return agendamento.dataAgendamento.year == hoje.year &&
                 agendamento.dataAgendamento.month == hoje.month &&
                 agendamento.dataAgendamento.day == hoje.day;
        }).toList();
        
        print('DEBUG: Total agendamentos: ${todosAgendamentos.length}');
        print('DEBUG: Agendamentos hoje: ${agendamentosHoje.length}');
        
        setState(() {
          _agendamentosHoje = agendamentosHoje;
          _isLoading = false;
        });
      } else {
        print('DEBUG: Response não foi sucesso ou widget não montado');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('DEBUG: Erro ao carregar agendamentos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hoje = DateFormat('dd/MM/yyyy').format(DateTime.now());

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
          'Dashboard Barbeiro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarAgendamentosHoje,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Olá, ${authProvider.user?.nome.split(' ').first ?? 'Barbeiro'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hoje, $hoje',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Card de resumo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agendamentos Hoje',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_agendamentosHoje.length}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFB84D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB84D).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFFFB84D),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CronogramaDiaScreen(),
                                ),
                              );
                            },
                            child: const Text('Cronograma'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CarteiraBarbeiroScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFFB84D)),
                            ),
                            child: const Text(
                              'Minha Carteira',
                              style: TextStyle(color: Color(0xFFFFB84D)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Lista de agendamentos de hoje
                  const Text(
                    'Próximos Agendamentos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_agendamentosHoje.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.free_breakfast,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum agendamento hoje',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aproveite para descansar!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._agendamentosHoje.take(3).map((agendamento) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAgendamentoCard(agendamento),
                      );
                    }).toList(),

                  if (_agendamentosHoje.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CronogramaDiaScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Ver todos (${_agendamentosHoje.length})',
                            style: const TextStyle(
                              color: Color(0xFFFFB84D),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildAgendamentoCard(AgendamentoModel agendamento) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB84D).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFFFB84D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agendamento.clienteNome ?? 'Cliente',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agendamento.servicoNome,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                agendamento.horario,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFB84D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${agendamento.valorServico.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}