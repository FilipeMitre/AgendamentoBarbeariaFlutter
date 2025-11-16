import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/horario_trabalho_model.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class ConfigurarHorariosScreen extends StatefulWidget {
  const ConfigurarHorariosScreen({super.key});

  @override
  State<ConfigurarHorariosScreen> createState() => _ConfigurarHorariosScreenState();
}

class _ConfigurarHorariosScreenState extends State<ConfigurarHorariosScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Dias da semana em português
  final List<String> _dias = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
  final List<String> _diasExibicao = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  
  // Mapa para armazenar horários de cada dia: dia -> {ativo, hora_inicio, hora_fim}
  late Map<String, Map<String, dynamic>> _horariosMap;
  
  // Controladores de texto para cada dia
  late Map<String, TextEditingController> _horaInicioControllers;
  late Map<String, TextEditingController> _horaFimControllers;

  @override
  void initState() {
    super.initState();
    _inicializarMapas();
    _carregarHorarios();
  }

  void _inicializarMapas() {
    _horariosMap = {};
    _horaInicioControllers = {};
    _horaFimControllers = {};
    
    for (final dia in _dias) {
      _horariosMap[dia] = {
        'ativo': false,
        'hora_inicio': '09:00',
        'hora_fim': '18:00',
      };
      _horaInicioControllers[dia] = TextEditingController(text: '09:00');
      _horaFimControllers[dia] = TextEditingController(text: '18:00');
    }
  }

  Future<void> _carregarHorarios() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user?.id == null || authProvider.token == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await ApiService.getHorariosTrabalho(
        authProvider.user!.id!,
        authProvider.token!,
      );

      if (response['success'] == true && response['horarios'] != null) {
        final horarios = response['horarios'] as List;
        
        setState(() {
          for (final horario in horarios) {
            final dia = horario['dia_semana'] as String;
            if (_horariosMap.containsKey(dia)) {
              _horariosMap[dia] = {
                'ativo': horario['ativo'] == 1 || horario['ativo'] == true,
                'hora_inicio': horario['hora_inicio'] ?? '09:00',
                'hora_fim': horario['hora_fim'] ?? '18:00',
              };
              _horaInicioControllers[dia]!.text = horario['hora_inicio'] ?? '09:00';
              _horaFimControllers[dia]!.text = horario['hora_fim'] ?? '18:00';
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar horários: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selecionarHora(String dia, bool isInicio) async {
    final controller = isInicio ? _horaInicioControllers[dia]! : _horaFimControllers[dia]!;
    final timeString = controller.text;
    final partes = timeString.split(':');
    final hora = int.tryParse(partes[0]) ?? 9;
    final minuto = int.tryParse(partes.length > 1 ? partes[1] : '0') ?? 0;

    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hora, minute: minuto),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF1A1A1A),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodBorderSide: const BorderSide(color: Color(0xFFFFB84D)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        final novaHora = '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
        controller.text = novaHora;
        if (isInicio) {
          _horariosMap[dia]!['hora_inicio'] = novaHora;
        } else {
          _horariosMap[dia]!['hora_fim'] = novaHora;
        }
      });
    }
  }

  bool _validarHorarios() {
    for (final dia in _dias) {
      if (_horariosMap[dia]!['ativo'] == true) {
        final horaInicio = _horaInicioControllers[dia]!.text;
        final horaFim = _horaFimControllers[dia]!.text;

        if (horaInicio.isEmpty || horaFim.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${HorarioTrabalhoModel.nomeDia(dia)}: preencha os horários')),
          );
          return false;
        }

        // Comparar horas
        final partes1 = horaInicio.split(':');
        final partes2 = horaFim.split(':');
        final minutos1 = int.parse(partes1[0]) * 60 + int.parse(partes1[1]);
        final minutos2 = int.parse(partes2[0]) * 60 + int.parse(partes2[1]);

        if (minutos2 <= minutos1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${HorarioTrabalhoModel.nomeDia(dia)}: horário final deve ser após o inicial')),
          );
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _salvarHorarios() async {
    if (!_validarHorarios()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user?.id == null || authProvider.token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: usuário não autenticado')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Preparar dados para envio
      final horariosParaEnviar = <Map<String, dynamic>>[];
      for (final dia in _dias) {
        horariosParaEnviar.add({
          'dia_semana': dia,
          'hora_inicio': _horaInicioControllers[dia]!.text,
          'hora_fim': _horaFimControllers[dia]!.text,
          'ativo': _horariosMap[dia]!['ativo'] ?? false,
        });
      }

      final response = await ApiService.atualizarHorariosTrabalho(
        authProvider.user!.id!,
        horariosParaEnviar,
        authProvider.token!,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Horários salvos com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(response['message'] ?? 'Erro ao salvar horários');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _horaInicioControllers.values) {
      controller.dispose();
    }
    for (final controller in _horaFimControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Horários de Trabalho'),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB84D)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card informativo
                  Card(
                    color: const Color(0xFF2A2A2A),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Selecione os dias e horários em que você trabalha. O sistema gerará automaticamente os slots de 30 minutos.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Lista de dias
                  ..._dias.asMap().entries.map((entry) {
                    final indice = entry.key;
                    final dia = entry.value;
                    final diaExibicao = _diasExibicao[indice];
                    
                    return Column(
                      children: [
                        Card(
                          color: const Color(0xFF2A2A2A),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                // Cabeçalho com toggle
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        diaExibicao,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _horariosMap[dia]!['ativo'] ?? false,
                                      activeColor: const Color(0xFFFFB84D),
                                      onChanged: (value) {
                                        setState(() {
                                          _horariosMap[dia]!['ativo'] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                
                                // Horários
                                if (_horariosMap[dia]!['ativo'] == true) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // Hora de início
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Início',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () => _selecionarHora(dia, true),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xFFFFB84D)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _horaInicioControllers[dia]!.text,
                                                  style: const TextStyle(
                                                    color: Color(0xFFFFB84D),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Hora de fim
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Fim',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () => _selecionarHora(dia, false),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xFFFFB84D)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _horaFimControllers[dia]!.text,
                                                  style: const TextStyle(
                                                    color: Color(0xFFFFB84D),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  
                  // Botão de salvar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _salvarHorarios,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Salvar Horários'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
