import '../database/database_helper.dart';
import '../models/credit_transaction_model.dart';

class CreditTransactionDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar transação
  Future<int> create(CreditTransactionModel transaction) async {
    final db = await dbHelper.database;
    // Primeiro buscar a carteira do usuário
    final carteiraResult = await db.query('SELECT id FROM carteiras WHERE id_cliente = ?', [transaction.userId]);
    if (carteiraResult.isEmpty) return 0;
    
    final carteiraId = carteiraResult.first['id'];
    final result = await db.query(
      'INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento) VALUES (?, ?, ?, ?)',
      [carteiraId, transaction.amount, transaction.type, null]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Buscar transação por ID
  Future<CreditTransactionModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT t.*, c.id_cliente FROM transacoes t JOIN carteiras c ON t.id_carteira = c.id WHERE t.id = ?',
      [id]
    );
    
    if (result.isNotEmpty) {
      final row = result.first;
      return CreditTransactionModel(
        id: row['id'],
        userId: row['id_cliente'],
        type: row['tipo'],
        amount: double.parse(row['valor'].toString()),
        description: 'Transação',
        status: 'completed',
        createdAt: row['criado_em'].toString(),
      );
    }
    return null;
  }

  // Listar transações de um usuário
  Future<List<CreditTransactionModel>> getByUserId(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT t.*, c.id_cliente FROM transacoes t JOIN carteiras c ON t.id_carteira = c.id WHERE c.id_cliente = ? ORDER BY t.criado_em DESC',
      [userId]
    );
    
    return result.map((row) => CreditTransactionModel(
      id: row['id'],
      userId: row['id_cliente'],
      type: row['tipo'],
      amount: double.parse(row['valor'].toString()),
      description: 'Transação',
      status: 'completed',
      createdAt: row['criado_em'].toString(),
    )).toList();
  }

  // Listar transações por tipo
  Future<List<CreditTransactionModel>> getByType(
    int userId,
    String type,
  ) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT t.*, c.id_cliente FROM transacoes t JOIN carteiras c ON t.id_carteira = c.id WHERE c.id_cliente = ? AND t.tipo = ? ORDER BY t.criado_em DESC',
      [userId, type]
    );
    
    return result.map((row) => CreditTransactionModel(
      id: row['id'],
      userId: row['id_cliente'],
      type: row['tipo'],
      amount: double.parse(row['valor'].toString()),
      description: 'Transação',
      status: 'completed',
      createdAt: row['criado_em'].toString(),
    )).toList();
  }

  // Adicionar créditos (recarga)
  Future<int> addCredit({
    required int userId,
    required double amount,
    required String description,
    String? paymentMethod,
  }) async {
    final db = await dbHelper.database;
    
    // Buscar carteira do usuário
    final carteiraResult = await db.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
    if (carteiraResult.isEmpty) return 0;
    
    final carteiraId = carteiraResult.first['id'];
    
    // Inserir transação
    final result = await db.query(
      'INSERT INTO transacoes (id_carteira, valor, tipo) VALUES (?, ?, ?)',
      [carteiraId, amount, 'credito']
    );
    
    // Atualizar saldo da carteira
    await db.query(
      'UPDATE carteiras SET saldo = saldo + ? WHERE id = ?',
      [amount, carteiraId]
    );
    
    return result.isNotEmpty ? 1 : 0;
  }

  // Debitar créditos (uso)
  Future<int> debitCredit({
    required int userId,
    required double amount,
    required String description,
  }) async {
    final db = await dbHelper.database;
    
    // Buscar carteira do usuário
    final carteiraResult = await db.query('SELECT id, saldo FROM carteiras WHERE id_cliente = ?', [userId]);
    if (carteiraResult.isEmpty) return 0;
    
    final carteira = carteiraResult.first;
    final carteiraId = carteira['id'];
    final saldoAtual = double.parse(carteira['saldo'].toString());
    
    // Verificar se tem saldo suficiente
    if (saldoAtual < amount) return 0;
    
    // Inserir transação
    final result = await db.query(
      'INSERT INTO transacoes (id_carteira, valor, tipo) VALUES (?, ?, ?)',
      [carteiraId, amount, 'debito']
    );
    
    // Atualizar saldo da carteira
    await db.query(
      'UPDATE carteiras SET saldo = saldo - ? WHERE id = ?',
      [amount, carteiraId]
    );
    
    return result.isNotEmpty ? 1 : 0;
  }

  // Deletar transação
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('DELETE FROM transacoes WHERE id = ?', [id]);
    return result.isNotEmpty ? 1 : 0;
  }

  // Listar todas as transações
  Future<List<CreditTransactionModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT t.*, c.id_cliente FROM transacoes t JOIN carteiras c ON t.id_carteira = c.id ORDER BY t.criado_em DESC'
    );
    
    return result.map((row) => CreditTransactionModel(
      id: row['id'],
      userId: row['id_cliente'],
      type: row['tipo'],
      amount: double.parse(row['valor'].toString()),
      description: 'Transação',
      status: 'completed',
      createdAt: row['criado_em'].toString(),
    )).toList();
  }
}
