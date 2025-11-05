import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'confirmacao_screen.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  int _currentStep = 0;
  String? _selectedService;
  String? _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<Map<String, dynamic>> services = [
    {
      'name': 'Corte de Cabelo',
      'price': 40.00,
      'duration': '45 min',
      'icon': Icons.content_cut,
    },
    {
      'name': 'Barba',
      'price': 20.00,
      'duration': '30 min',
      'icon': Icons.face,
    },
    {
      'name': 'Completo',
      'price': 55.00,
      'duration': '1h 15min',
      'description': 'Corte + Barba',
      'icon': Icons.star,
    },
  ];

  final List<Map<String, String>> barbers = [
    {
      'name': 'Vinicius Brabo',
      'rating': '5.0',
      'specialty': 'Especialista em degradê',
    },
    {
      'name': 'Carlos Silva',
      'rating': '4.9',
      'specialty': 'Especialista em barba',
    },
    {
      'name': 'João Pedro',
      'rating': '4.8',
      'specialty': 'Cortes modernos',
    },
  ];

  final List<String> times = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
  ];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Ir para tela de confirmação
      if (_selectedService != null &&
          _selectedBarber != null &&
          _selectedDate != null &&
          _selectedTime != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmacaoScreen(
              barber: _selectedBarber!,
              day: _selectedDate!.day,
              time: _selectedTime!,
              package: _selectedService!,
            ),
          ),
        );
      }
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return _selectedBarber != null;
      case 2:
        return _selectedDate != null && _selectedTime != null;
      default:
        return false;
    }
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
          'Agendamento',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStepperProgress(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canProceed() ? AppColors.primary : AppColors.inputBorder,
                ),
                child: Text(
                  _currentStep == 2 ? 'Revisar agendamento' : 'Avançar',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperProgress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Serviço'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 0
                  ? AppColors.primary
                  : AppColors.inputBorder,
            ),
          ),
          _buildStepIndicator(1, 'Barbeiro'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 1
                  ? AppColors.primary
                  : AppColors.inputBorder,
            ),
          ),
          _buildStepIndicator(2, 'Data/Hora'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.inputBorder,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.black : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildServiceSelection();
      case 1:
        return _buildBarberSelection();
      case 2:
        return _buildDateTimeSelection();
      default:
        return Container();
    }
  }

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha o serviço',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Selecione o serviço desejado',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 24),
        ...services.map((service) => _buildServiceCard(service)),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isSelected = _selectedService == service['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = service['name'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'],
                color: isSelected ? Colors.black : AppColors.textSecondary,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (service['description'] != null) ...[
                    SizedBox(height: 4),
                    Text(
                      service['description'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    service['duration'],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${service['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha o barbeiro',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Selecione seu barbeiro preferido',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 24),
        ...barbers.map((barber) => _buildBarberCard(barber)),
      ],
    );
  }

  Widget _buildBarberCard(Map<String, String> barber) {
    final isSelected = _selectedBarber == barber['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBarber = barber['name'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barber['name']!,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    barber['specialty']!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.starYellow, size: 14),
                      SizedBox(width: 4),
                      Text(
                        barber['rating']!,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha data e horário',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Selecione o melhor dia e horário',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 24),

        // Calendar
        _buildCalendar(),
        SizedBox(height: 32),

        // Time slots
        if (_selectedDate != null) ...[
          Text(
            'Horários disponíveis',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          _buildTimeSlots(),
        ],
      ],
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    // Calcular primeiro dia do mês e dias no mês
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Domingo = 0

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Mês e Ano
          Text(
            '${monthNames[currentMonth - 1]} $currentYear',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),

          // Dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 12),

          // Grid de dias
          Wrap(
            spacing: 0,
            runSpacing: 8,
            children: List.generate(firstWeekday + daysInMonth, (index) {
              if (index < firstWeekday) {
                // Espaços vazios antes do primeiro dia
                return SizedBox(width: 40, height: 40);
              }

              final day = index - firstWeekday + 1;
              final date = DateTime(currentYear, currentMonth, day);
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = date;
                          _selectedTime = null; // Reset time
                        });
                      },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.secondary.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.secondary)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isPast
                            ? AppColors.textSecondary.withOpacity(0.3)
                            : isSelected
                                ? Colors.black
                                : AppColors.textPrimary,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    final now = DateTime.now();
    final isToday = _selectedDate != null &&
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: times.map((time) {
        final isSelected = _selectedTime == time;
        final timeHour = int.parse(time.split(':')[0]);
        final timeMinute = int.parse(time.split(':')[1]);
        final isPastTime = isToday && 
            (timeHour < now.hour || (timeHour == now.hour && timeMinute <= now.minute));
        
        return GestureDetector(
          onTap: isPastTime ? null : () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.inputBorder,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isPastTime
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : isSelected ? Colors.black : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}