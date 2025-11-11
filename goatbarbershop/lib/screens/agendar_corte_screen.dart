import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barbeiro_model.dart';
import '../models/servico_model.dart';
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

  // Dados mockados - depois virão da API
  final List<Map<String, dynamic>> _barbeiros = [
    {'id': 1, 'nome': 'Haku Santos', 'tipo': 'Haku Santos'},
    {'id': 2, 'nome': 'Luon Yog', 'tipo': 'Luon Yog'},
    {'id': 3, 'nome': 'Oui Uiga', 'tipo': 'Oui Uiga'},
  ];

  final List<DateTime> _diasDisponiveis = [
    DateTime(2025, 3, 10),
    DateTime(2025, 3, 11),
    DateTime(2025, 3, 12),
    DateTime(2025, 3, 13),
    DateTime(2025, 3, 14),
  ];

  final List<String> _horariosDisponiveis = [
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

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
              Row(
                children: _barbeiros.map((barbeiro) {
                  final isSelected = _selectedBarbeiro == barbeiro['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBarbeiro = barbeiro['id'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFB84D)
                                : const Color(0xFF333333),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              barbeiro['tipo'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

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
                    final isSelected = _selectedDate == data;
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
                            _selectedDate = data;
                          });
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

              const SizedBox(height: 32),

              // Horários disponíveis
              const Text(
                'Horários disponíveis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _horariosDisponiveis.map((horario) {
                  final isSelected = _selectedTime == horario;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = horario;
                      });
                    },
                    child: Container(
                      width: 80,
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
                      child: Text(
                        horario,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmarAgendamentoScreen(
                                barbeiro: widget.barbeiro,
                                barbeiroNome: _barbeiros
                                    .firstWhere((b) => b['id'] == _selectedBarbeiro)['nome'],
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
