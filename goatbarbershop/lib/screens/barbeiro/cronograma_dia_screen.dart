import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/agendamento_model.dart';
import 'detalhes_agendamento_barbeiro_dialog.dart';

class CronogramaDiaScreen extends StatefulWidget {
  const CronogramaDiaScreen({super.key});

  @override
  State<CronogramaDiaScreen> createState() => _CronogramaDiaScreenState();
}

class _CronogramaDiaScreenState extends State<CronogramaDiaScreen> {
  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  final List<DateTime> _diasDisponiveis = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  final List<String> _horariosDisponiveis = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
  ];

  final Map<String, AgendamentoModel> _agendamentos = {};

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user?.id == null || authProvider.token == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getAgendamentosBarbeiro(
        authProvider.user!.id!,
        _dataSelecionada,
        authProvider.token!,
      );

      if (response['success'] == true && mounted) {
        final agendamentos = (response['agendamentos'] as List)
            .map((json) => AgendamentoModel.fromJson(json))
            .toList();

        setState(() {
          _agendamentos.clear();
          for (var agendamento in agendamentos) {
            // Converter horario de HH:MM:SS para HH:MM
            String horarioFormatado = agendamento.horario;
            if (horarioFormatado.length > 5) {
              horarioFormatado = horarioFormatado.substring(0, 5);
            }
            _agendamentos[horarioFormatado] = agendamento;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar agendamentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarDetalhesAgendamento(AgendamentoModel agendamento) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => DetalhesAgendamentoBarbeiroDialog(
        agendamento: agendamento,
        onUpdate: _carregarAgendamentos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
          'Cronograma do dia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card da Barbearia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.content_cut,
                        color: Color(0xFFFFB84D),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GOATbarber',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFFB84D),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '5.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '0.5 km',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: const Text(
                        'Aberto',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nome do Barbeiro
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB84D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      authProvider.user?.nome ?? 'nome do barbeiro',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dias disponíveis
              const Text(
                'Dias disponíveis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _diasDisponiveis.map((data) {
                    final isSelected = DateUtils.isSameDay(_dataSelecionada, data);
                    final diaSemana = DateFormat('EEE', 'pt_BR')
                        .format(data)
                        .toUpperCase()
                        .substring(0, 3);
                    final dia = DateFormat('d').format(data);

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _dataSelecionada = data;
                          });
                          _carregarAgendamentos();
                        },
                        child: Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFB84D)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFB84D)
                                  : const Color(0xFF333333),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dia,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                diaSemana,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Horários marcados
              const Text(
                'Horários marcados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Grid de horários
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _horariosDisponiveis.map((horario) {
                    final agendamento = _agendamentos[horario];
                    final isMarcado = agendamento != null;
                    final isConcluido = agendamento?.status == 'concluido';
                    final isCancelado = agendamento?.status == 'cancelado';

                    Color corFundo = const Color(0xFF1A1A1A);
                    Color corBorda = const Color(0xFF333333);
                    Color corTexto = Colors.white;

                    if (isMarcado) {
                      if (isConcluido) {
                        corFundo = const Color(0xFF4CAF50);
                        corBorda = const Color(0xFF4CAF50);
                        corTexto = Colors.white;
                      } else if (isCancelado) {
                        corFundo = const Color(0xFFF44336);
                        corBorda = const Color(0xFFF44336);
                        corTexto = Colors.white;
                      } else {
                        corFundo = const Color(0xFFFFB84D);
                        corBorda = const Color(0xFFFFB84D);
                        corTexto = Colors.black;
                      }
                    }

                    return GestureDetector(
                      onTap: isMarcado
                          ? () => _mostrarDetalhesAgendamento(agendamento)
                          : null,
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: corFundo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: corBorda),
                        ),
                        child: Column(
                          children: [
                            Text(
                              horario,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: corTexto,
                              ),
                            ),
                            if (isMarcado) ...[
                              const SizedBox(height: 4),
                              Text(
                                agendamento.clienteNome ?? 'Cliente',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: corTexto.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (isConcluido) ...[
                              const SizedBox(height: 2),
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.white,
                              ),
                            ] else if (isCancelado) ...[
                              const SizedBox(height: 2),
                              const Icon(
                                Icons.cancel,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
