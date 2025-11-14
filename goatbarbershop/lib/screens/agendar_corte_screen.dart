import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/barbeiro_model.dart';
import '../models/servico_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
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
  List<String> _horariosOcupados = [];
  List<ServicoModel> _servicos = [];
  bool _isLoadingServicos = false;

  // Getter que filtra barbeiros, excluindo o usuário logado (se for barbeiro)
  List<Map<String, dynamic>> get _barbeirosDisponiveis {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuarioLogado = authProvider.user;

    if (usuarioLogado?.tipoUsuario == 'barbeiro') {
      // Se o usuário logado é barbeiro, remove ele da lista
      return _barbeiros.where((b) => b['id'] != usuarioLogado?.id).toList();
    }
    // Se é cliente, mostra todos
    return _barbeiros;
  }

  bool get _canAdvance =>
      _selectedBarbeiro != null &&
      _selectedDate != null &&
      _selectedTime != null &&
      _selectedPacote != null;

  ServicoModel? get _servicoSelecionado {
    return _servicos.firstWhere(
      (servico) => servico.id == _selectedPacote,
      orElse: () => ServicoModel(
        id: 0,
        nome: 'Serviço não encontrado',
        preco: 0.0,
        duracaoMinutos: 0,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedBarbeiro = widget.barbeiro.id;
    _carregarServicos();
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

  Future<void> _carregarServicos() async {
    setState(() {
      _isLoadingServicos = true;
    });

    try {
      final response = await ApiService.getServicosAtivos();
      if (response['success'] && mounted) {
        setState(() {
          _servicos = (response['servicos'] as List)
              .map((servico) => ServicoModel.fromJson(servico))
              .toList();
        });
      }
    } catch (e) {
      // Em caso de erro, usar serviços padrão
      if (mounted) {
        setState(() {
          _servicos = [
            ServicoModel(
              id: 1,
              nome: 'Corte Masculino',
              descricao: 'Corte de cabelo masculino tradicional',
              preco: 35.00,
              duracaoMinutos: 30,
            ),
            ServicoModel(
              id: 2,
              nome: 'Barba',
              descricao: 'Aparar e modelar barba',
              preco: 25.00,
              duracaoMinutos: 30,
            ),
            ServicoModel(
              id: 3,
              nome: 'Corte + Barba (Completo)',
              descricao: 'Pacote completo: corte e barba',
              preco: 50.00,
              duracaoMinutos: 60,
            ),
          ];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingServicos = false;
        });
      }
    }
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
          _horariosOcupados = List<String>.from(response['horarios_ocupados'] ?? []);
        });
      }
    } catch (e) {
      // Em caso de erro, usar horários padrão filtrados
      if (mounted) {
        setState(() {
          _horariosDisponiveis = _gerarHorariosPadrao();
          _horariosOcupados = [];
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
    // Este método é um fallback caso a API não retorne dados
    // Agora que temos dados do banco, isso não deve ser chamado
    return [];
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
                children: _barbeirosDisponiveis.map((barbeiro) {
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

              const SizedBox(height: 12),

              // Legenda dos horários
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendaItem(
                    color: const Color(0xFF1A1A1A),
                    borderColor: const Color(0xFF333333),
                    label: 'Disponível',
                  ),
                  _buildLegendaItem(
                    color: const Color(0xFF8B0000),
                    borderColor: Colors.red,
                    label: 'Ocupado',
                  ),
                  _buildLegendaItem(
                    color: const Color(0xFFFFB84D),
                    borderColor: const Color(0xFFFFB84D),
                    label: 'Selecionado',
                    textColor: Colors.black,
                  ),
                ],
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
              else if (_selectedDate != null)
                _buildHorariosGrid()
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: const Center(
                    child: Text(
                      'Selecione uma data para ver os horários',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Escolha seu serviço
              const Text(
                'Escolha seu serviço',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              if (_isLoadingServicos)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                )
              else
                ..._servicos.map((servico) {
                  final isSelected = _selectedPacote == servico.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPacote = servico.id;
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
                                _getServiceIcon(servico.nome),
                                color: isSelected ? Colors.black : const Color(0xFFFFB84D),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          servico.nome,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFFFFB84D)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${servico.preco.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFFFFB84D)
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          servico.descricao ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${servico.duracaoMinutos} min',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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

                          final servicoSelecionado = _servicoSelecionado;
                          if (servicoSelecionado != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmarAgendamentoScreen(
                                  barbeiro: selectedBarbeiroModel,
                                  barbeiroNome: selected['nome'],
                                  data: _selectedDate!,
                                  horario: _selectedTime!,
                                  servico: servicoSelecionado,
                                ),
                              ),
                            );
                          }
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

  Widget _buildLegendaItem({
    required Color color,
    required Color borderColor,
    required String label,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHorariosGrid() {
    // Usar os horários disponíveis retornados da API
    // Se a API não retornou nada, mostrar mensagem
    if (_horariosDisponiveis.isEmpty && _horariosOcupados.isEmpty) {
      return Container(
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
      );
    }

    // Todos os horários possíveis do dia (incluindo ocupados)
    final todosHorarios = [
      ..._horariosDisponiveis,
      ..._horariosOcupados,
    ].toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: todosHorarios.length,
      itemBuilder: (context, index) {
        final horario = todosHorarios[index];
        final isSelected = _selectedTime == horario;
        final isDisponivel = _horariosDisponiveis.contains(horario);
        final isOcupado = _horariosOcupados.contains(horario);
        
        // Verificar se o horário já passou (apenas para hoje)
        bool jaPassou = false;
        if (_selectedDate != null) {
          final hoje = DateTime.now();
          if (_selectedDate!.day == hoje.day && 
              _selectedDate!.month == hoje.month && 
              _selectedDate!.year == hoje.year) {
            final horaAtual = hoje.hour;
            final minutoAtual = hoje.minute;
            final [hora, minuto] = horario.split(':').map(int.parse).toList();
            jaPassou = hora < horaAtual || (hora == horaAtual && minuto <= minutoAtual + 30);
          }
        }
        
        return GestureDetector(
          onTap: (isDisponivel) && !jaPassou ? () async {
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
          } : null,
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
              color: isSelected 
                  ? null 
                  : isOcupado || jaPassou
                      ? const Color(0xFF8B0000) // Vermelho escuro para ocupados
                      : isDisponivel
                          ? const Color(0xFF1A1A1A) // Cinza escuro para disponíveis
                          : const Color(0xFF2A2A2A), // Cinza médio para indisponíveis
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFB84D)
                    : isOcupado || jaPassou
                        ? Colors.red
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    horario,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                          ? Colors.black 
                          : isOcupado || jaPassou
                              ? Colors.white70
                              : Colors.white,
                    ),
                  ),
                  if (isOcupado)
                    const SizedBox(height: 2),
                  if (isOcupado)
                    const Text(
                      'Ocupado',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  if (jaPassou && !isOcupado)
                    const SizedBox(height: 2),
                  if (jaPassou && !isOcupado)
                    const Text(
                      'Passou',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('completo') || name.contains('corte + barba')) {
      return Icons.check_circle;
    } else if (name.contains('barba')) {
      return Icons.face;
    } else if (name.contains('corte') || name.contains('cabelo')) {
      return Icons.content_cut;
    } else if (name.contains('coloração') || name.contains('tintura')) {
      return Icons.palette;
    } else if (name.contains('hidratação') || name.contains('tratamento')) {
      return Icons.water_drop;
    } else if (name.contains('escova')) {
      return Icons.brush;
    } else if (name.contains('luzes') || name.contains('mechas')) {
      return Icons.highlight;
    } else {
      return Icons.content_cut;
    }
  }
}
