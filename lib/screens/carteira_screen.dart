import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'recarga_screen.dart';
import '../navigation/main_navigation.dart';
import '../services/user_service.dart';
import '../services/credit_service.dart';

class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  double saldoDisponivel = 0.00;
  String userName = 'Usuário';
  int? userId;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() async {
    final name = await UserService.getUserName();
    final id = await UserService.getUserId();
    print('=== CARTEIRA DEBUG ===');
    print('Nome do usuário: $name');
    print('ID do usuário: $id');
    
    final credits = await CreditService.getCredits(id);
    print('Créditos carregados: $credits');
    print('=====================');
    
    setState(() {
      userName = name;
      userId = id;
      saldoDisponivel = credits;
    });
  }

  // Histórico de transações
  final List<Map<String, dynamic>> transacoes = [
    {
      'tipo': 'recarga',
      'valor': 50.00,
      'data': '28 Out, 2024',
      'descricao': 'Recarga via Pix',
    },
    {
      'tipo': 'uso',
      'valor': -55.00,
      'data': '25 Out, 2024',
      'descricao': 'Corte Completo - GOATbarber',
    },
    {
      'tipo': 'recarga',
      'valor': 100.00,
      'data': '20 Out, 2024',
      'descricao': 'Recarga via Pix',
    },
    {
      'tipo': 'uso',
      'valor': -40.00,
      'data': '18 Out, 2024',
      'descricao': 'Corte de Cabelo - GOATbarber',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          ),
        ),
        title: Text(
          'minha carteira',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com saudação
              Row(
                children: [
                  Text(
                    UserService.getGreeting(userName),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.waving_hand, color: AppColors.primary, size: 20),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Salvador-BA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 32),

              // Card de Créditos
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Créditos',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Disponível',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'R\$${saldoDisponivel.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecargaScreen(
                                saldoAtual: saldoDisponivel,
                              ),
                            ),
                          );

                          if (resultado != null && resultado is double) {
                            // O resultado já é o novo saldo total, apenas recarregar
                            _loadUserData(); // Recarregar dados do banco
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Depositar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Histórico de transações
              Text(
                'Histórico',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              // Lista de transações
              ...transacoes.map((transacao) => _buildTransacaoCard(transacao)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransacaoCard(Map<String, dynamic> transacao) {
    final isRecarga = transacao['tipo'] == 'recarga';
    final valor = transacao['valor'] as double;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isRecarga
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRecarga ? Icons.add : Icons.remove,
              color: isRecarga ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao['descricao'],
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transacao['data'],
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${valor >= 0 ? '+' : ''}R\$${valor.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isRecarga ? AppColors.success : AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}