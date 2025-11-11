import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/barber_wallet_service.dart';
import '../../services/auth_service.dart';

class BarberWalletScreen extends StatefulWidget {
  const BarberWalletScreen({super.key});

  @override
  State<BarberWalletScreen> createState() => _BarberWalletScreenState();
}

class _BarberWalletScreenState extends State<BarberWalletScreen> {
  final BarberWalletService _walletService = BarberWalletService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic> _walletData = {};
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  int? _barberId;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      setState(() => _isLoading = true);
      
      final user = await _authService.getCurrentUser();
      if (user != null && user.id != null) {
        _barberId = user.id;
        
        final walletInfo = await _walletService.getWalletInfo(user.id!);
        final transactions = await _walletService.getTransactionHistory(user.id!, limit: 10);
        
        setState(() {
          _walletData = walletInfo;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar carteira: $e')),
        );
      }
    }
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Fazer Depósito',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0 && _barberId != null) {
                try {
                  await _walletService.makeDeposit(
                    _barberId!,
                    amount,
                    descriptionController.text.isEmpty ? 'Depósito' : descriptionController.text,
                  );
                  Navigator.pop(context);
                  _loadWalletData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Depósito realizado com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao fazer depósito: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Depositar'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'ambos';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Fazer Saque',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: AppColors.cardBackground,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Tipo de Saque',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'saldo', child: Text('Apenas Saldo')),
                  DropdownMenuItem(value: 'receita', child: Text('Apenas Receita')),
                  DropdownMenuItem(value: 'ambos', child: Text('Saldo + Receita')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && _barberId != null) {
                  try {
                    await _walletService.makeWithdrawal(
                      _barberId!,
                      amount,
                      selectedType,
                      descriptionController.text.isEmpty ? 'Saque' : descriptionController.text,
                    );
                    Navigator.pop(context);
                    _loadWalletData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saque realizado com sucesso!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao fazer saque: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text('Sacar'),
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
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Minha Carteira',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadWalletData,
            icon: Icon(Icons.refresh, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWalletData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cards de saldo
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceCard(
                            'Saldo Depósitos',
                            _walletData['saldo_depositos']?.toString() ?? '0.00',
                            AppColors.primary,
                            Icons.account_balance_wallet,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildBalanceCard(
                            'Receita Serviços',
                            _walletData['receita_servicos']?.toString() ?? '0.00',
                            AppColors.success,
                            Icons.monetization_on,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Total disponível
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Disponível',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'R\$ ${_walletData['total_disponivel']?.toString() ?? '0.00'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showDepositDialog,
                            icon: Icon(Icons.add, size: 20),
                            label: Text('Depositar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showWithdrawalDialog,
                            icon: Icon(Icons.remove, size: 20),
                            label: Text('Sacar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Histórico de transações
                    Text(
                      'Últimas Transações',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16),

                    if (_transactions.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: AppColors.textSecondary,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma transação ainda',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Suas transações aparecerão aqui',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._transactions.map((transaction) => _buildTransactionCard(transaction)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'R\$ $value',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isCredit = transaction['tipo'] == 'credito';
    final color = isCredit ? AppColors.success : AppColors.error;
    final icon = isCredit ? Icons.add : Icons.remove;

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['tipo_operacao'] ?? 'Transação',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['descricao'] ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}R\$ ${transaction['valor']?.toString() ?? '0.00'}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}