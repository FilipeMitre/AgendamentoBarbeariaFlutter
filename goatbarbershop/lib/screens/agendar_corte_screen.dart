import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/barbeiro_model.dart';
import '../models/servico_model.dart';
import '../services/api_service.dart';
import 'confirmar_agendamento_screen.dart';

class AgendarCorteScreen extends StatefulWidget {
  final BarbeiroModel barbeiro;

  const AgendarCorteScreen({
    super.key,
    required this.barbeiro,
  });

  @override
  State<AgendarCorteScreen> createState() => _AgendarCorteScreenState();
}

class _AgendarCorteScreenState extends State<AgendarCorteScreen> {
  int? _selectedBarbeiro;
  DateTime? _selectedDate;
  String? _selectedTime;
  int? _selectedPacote;
  bool _isLoadingHorarios = false;
  bool _isLoadingDias = false;
  Timer? _refreshTimer;

  // Dados mockados - depois virão da API
  final List<Map<String, dynamic>> _barbeiros = [
    {'id': 1, 'nome': 'Haku Santos', 'tipo': 'Haku Santos'},
    {'id': 2, 'nome': 'Luon Yog', 'tipo': 'Luon Yog'},
    {'id': 3, 'nome': 'Oui Uiga', 'tipo': 'Oui Uiga'},
  ];

  List<DateTime> _diasDisponiveis = [];
  List<String> _horariosDisponiveis = [];

  final List<Map<String, dynamic>> _pacotes = [
    {
      'id': 1,
      'nome': 'Completo',
      'descricao': 'Pacote com corte de cabelo e barba',
      'icon': Icons.check_circle,
    },
    {
      'id': 2,
      'nome': 'Cabelo',
      'descricao': 'Apenas corte de cabelo',
      'icon': Icons.content_cut,
    },
  ];

  bool get _canAdvance =>
      _selectedBarbeiro != null &&
      _selectedDate != null &&
      _selectedTime != null &&
      _selectedPacote != null;

  @override
  void initState() {
    super.initState();
    _selectedBarbeiro = widget.barbeiro.id;
    _carregarDiasDisponiveis();
    // Atualizar a cada 30 segundos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_selectedDate != null && _selectedBarbeiro != null) {
        _carregarHorariosDisponiveis();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarDiasDisponiveis() async {
    if (_selectedBarbeiro == null) return;
    
    setState(() {
      _isLoadingDias = true;
    });

    try {
      final response = await ApiService.getDiasDisponiveis(_selectedBarbeiro!);
      if (response['success'] && mounted) {
        setState(() {
          _diasDisponiveis = (response['dias'] as List)
              .map((dia) => DateTime.parse(dia['data']))
              .toList();
        });
      }
    } catch (e) {
      // Em caso de erro, usar dias padrão
      if (mounted) {
        setState(() {
          _diasDisponiveis = _gerarDiasPadrao();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDias = false;
        });
      }
    }
  }

  List<DateTime> _gerarDiasPadrao() {
    final dias = <DateTime>[];
    final hoje = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final data = DateTime(hoje.year, hoje.month, hoje.day + i);
      if (data.weekday != 7) { // Excluir domingos
        dias.add(data);
      }
    }
    return dias;
  }

  Future<void> _carregarHorariosDisponiveis() async {
    if (_selectedBarbeiro == null || _selectedDate == null) return;
    
    setState(() {
      _isLoadingHorarios = true;
      _selectedTime = null; // Limpar seleção anterior
    });

    try {
      final response = await ApiService.getHorariosDisponiveis(
        _selectedBarbeiro!,
        _selectedDate!,
      );
      
      if (response['success'] && mounted) {
        setState(() {
          _horariosDisponiveis = List<String>.from(response['horarios']);
        });
      }
    } catch (e) {
      // Em caso de erro, usar horários padrão filtrados
      if (mounted) {
        setState(() {
          _horariosDisponiveis = _gerarHorariosPadrao();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHorarios = false;
        });
      }
    }
  }

  List<String> _gerarHorariosPadrao() {
    final horariosBase = [
      '08:00', '09:00', '10:00', '11:00', '12:00',
      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
    ];

    // Se for hoje, filtrar horários que já passaram
    if (_selectedDate != null) {
      final hoje = DateTime.now();
      if (_selectedDate!.day == hoje.day && 
          _selectedDate!.month == hoje.month && 
          _selectedDate!.year == hoje.year) {
        final horaAtual = hoje.hour;
        return horariosBase.where((horario) {
          final hora = int.parse(horario.split(':')[0]);
          return hora > horaAtual;
        }).toList();
      }
    }
    
    return horariosBase;
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
          'Agendar corte',
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
              // Informações da barbearia
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.content_cut,
                        color: Color(0xFFFFB84D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.barbeiro.nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                              Text(
                                '${widget.barbeiro.avaliacao}',
                                style: const TextStyle(
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
                              Text(
                                '${widget.barbeiro.distancia} km',
                                style: const TextStyle(
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Text(
                        widget.barbeiro.status,
                        style: const TextStyle(
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

              // Seleção de barbeiro
              const Text(
                'Escolha o barbeiro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _barbeiros.map((barbeiro) {
                  final isSelected = _selectedBarbeiro == barbeiro['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBarbeiro = barbeiro['id'];
                        _selectedDate = null;
                        _selectedTime = null;
                        _horariosDisponiveis.clear();
                      });
                      _carregarDiasDisponiveis();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFB84D)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF333333),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            barbeiro['tipo'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Dias disponíveis
              const Text(
                'Selecione o dia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              if (_isLoadingDias)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                )
              else
                Container(
                  height: 100,
                  child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _diasDisponiveis.length,
                  itemBuilder: (context, index) {
                    final data = _diasDisponiveis[index];
                    final isSelected = _selectedDate == data;
                    final diaSemana = DateFormat('EEEE', 'pt_BR')
                        .format(data)
                        .toLowerCase();
                    final diaSemanaCurto = diaSemana.substring(0, 3);
                    final dia = DateFormat('d').format(data);
                    final mes = DateFormat('MMM', 'pt_BR').format(data);

                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                        right: index == _diasDisponiveis.length - 1 ? 0 : 8,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = data;
                          });
                          _carregarHorariosDisponiveis();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFFB84D),
                                      Color(0xFFFF9800),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFB84D)
                                  : const Color(0xFF333333),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFB84D).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                diaSemanaCurto.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.black87 : Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dia,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mes.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.black87 : Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Horários disponíveis
              const Text(
                'Escolha o horário',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              if (_isLoadingHorarios)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                )
              else if (_horariosDisponiveis.isEmpty && _selectedDate != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: const Center(
                    child: Text(
                      'Nenhum horário disponível para esta data',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: _horariosDisponiveis.length,
                itemBuilder: (context, index) {
                  final horario = _horariosDisponiveis[index];
                  final isSelected = _selectedTime == horario;
                  
                  return GestureDetector(
                    onTap: () async {
                      // Verificar disponibilidade antes de selecionar
                      if (_selectedBarbeiro != null && _selectedDate != null) {
                        final dataFormatada = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                        final response = await ApiService.verificarDisponibilidade(
                          barbeiroId: _selectedBarbeiro!,
                          dataAgendamento: dataFormatada,
                          horario: horario,
                        );
                        
                        if (response['success'] && response['disponivel']) {
                          setState(() {
                            _selectedTime = horario;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Este horário não está mais disponível'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          _carregarHorariosDisponiveis(); // Atualizar lista
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFB84D),
                                  Color(0xFFFF9800),
                                ],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF333333),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFB84D).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          horario,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Escolha seu pacote
              const Text(
                'Escolha seu pacote',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              ..._pacotes.map((pacote) {
                final isSelected = _selectedPacote == pacote['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPacote = pacote['id'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFB84D).withOpacity(0.1)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF333333),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFB84D)
                                  : const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              pacote['icon'],
                              color: isSelected ? Colors.black : const Color(0xFFFFB84D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pacote['nome'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFFFFB84D)
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pacote['descricao'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFFB84D),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 32),

              // Botão Avançar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canAdvance
                      ? () async {
                          // Verificar disponibilidade final antes de avançar
                          final dataFormatada = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          final response = await ApiService.verificarDisponibilidade(
                            barbeiroId: _selectedBarbeiro!,
                            dataAgendamento: dataFormatada,
                            horario: _selectedTime!,
                          );
                          
                          if (!response['success'] || !response['disponivel']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Este horário não está mais disponível. Escolha outro horário.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            _carregarHorariosDisponiveis();
                            return;
                          }

                          final selected = _barbeiros.firstWhere((b) => b['id'] == _selectedBarbeiro);
                          final selectedBarbeiroModel = BarbeiroModel(
                            id: selected['id'],
                            nome: selected['nome'],
                            foto: null,
                            avaliacao: 0.0,
                            distancia: 0.0,
                            status: 'Aberto',
                            endereco: null,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmarAgendamentoScreen(
                                barbeiro: selectedBarbeiroModel,
                                barbeiroNome: selected['nome'],
                                data: _selectedDate!,
                                horario: _selectedTime!,
                                pacote: _pacotes
                                    .firstWhere((p) => p['id'] == _selectedPacote)['nome'],
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canAdvance
                        ? const Color(0xFFFFB84D)
                        : const Color(0xFF333333),
                  ),
                  child: Text(
                    'Avançar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canAdvance ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
