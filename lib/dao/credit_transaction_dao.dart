import '../database/database_helper.dart';
import '../models/credit_transaction_model.dart';

class CreditTransactionDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar transação
  Future<int> create(CreditTransactionModel transaction) async {
    try {
      // Primeiro, buscar ou criar carteira do usuário
      final walletResult = await dbHelper.query('SELECT id FROM carteiras WHERE id_cliente = ?', [transaction.userId]);
      int walletId;
      
      if (walletResult.isEmpty) {
        // Criar carteira se não existir
        final createWallet = await dbHelper.executeQuery(
          'INSERT INTO carteiras (id_cliente, saldo) VALUES (?, ?)',
          [transaction.userId, 0.0]
        );
        walletId = createWallet.insertId ?? 0;
      } else {
        walletId = walletResult.first['id'];
      }
      
      // Criar transação
      final results = await dbHelper.executeQuery(
        'INSERT INTO transacoes (id_carteira, valor, tipo, descricao) VALUES (?, ?, ?, ?)',
        [walletId, transaction.amount, transaction.type, transaction.description]
      );
      return results.insertId ?? 0;
    } catch (e) {
      print('Erro ao criar transação: $e');
      return 0;
    }
  }

  // Buscar transações por usuário
  Future<List<CreditTransactionModel>> getByUserId(int userId) async {
    try {
      final result = await dbHelper.query(
        '''SELECT t.*, c.id_cliente FROM transacoes t 
           JOIN carteiras c ON t.id_carteira = c.id 
           WHERE c.id_cliente = ? 
           ORDER BY t.criado_em DESC''',
        [userId]
      );
      
      return result.map((row) => CreditTransactionModel(
        id: row['id'],
        userId: row['id_cliente'],
        amount: double.parse(row['valor'].toString()),
        type: row['tipo'],
        description: row['descricao'] ?? '',
        createdAt: DateTime.now().toIso8601String(),
      )).toList();
    } catch (e) {
      print('Erro ao buscar transações do usuário: $e');
      return [];
    }
  }

  // Buscar transações por carteira (método mantido para compatibilidade)
  Future<List<CreditTransactionModel>> getByWalletId(int walletId) async {
    try {
      final result = await dbHelper.query(
        'SELECT t.*, c.id_cliente FROM transacoes t JOIN carteiras c ON t.id_carteira = c.id WHERE t.id_carteira = ? ORDER BY t.criado_em DESC',
        [walletId]
      );
      
      return result.map((row) => CreditTransactionModel(
        id: row['id'],
        userId: row['id_cliente'],
        amount: double.parse(row['valor'].toString()),
        type: row['tipo'],
        description: row['descricao'] ?? '',
        createdAt: DateTime.now().toIso8601String(),
      )).toList();
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return [];
    }
  }

  // Buscar transações por cliente (alias para getByUserId)
  Future<List<CreditTransactionModel>> getByClientId(int clientId) async {
    return getByUserId(clientId);
  }
}