import '../database/database_helper.dart';

class CreditService {
  static final dbHelper = DatabaseHelper.instance;
  
  static Future<double> getCredits([int? userId]) async {
    if (userId == null) return 0.0;
    
    try {
      final result = await dbHelper.query('SELECT saldo FROM carteiras WHERE id_cliente = ?', [userId]);
      
      if (result.isNotEmpty) {
        final credits = double.parse(result.first['saldo'].toString());
        print('Créditos carregados do MySQL: $credits para usuário $userId');
        return credits;
      }
      
      print('Carteira não encontrada para usuário $userId');
      return 0.0;
    } catch (e) {
      print('Erro ao buscar créditos no MySQL: $e');
      return 0.0;
    }
  }
  
  static Future<void> setCredits(double credits, [int? userId]) async {
    if (userId == null) return;
    
    try {
      // Verificar se a carteira existe
      final existingWallet = await dbHelper.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
      
      if (existingWallet.isEmpty) {
        // Criar carteira se não existir
        await dbHelper.executeQuery('INSERT INTO carteiras (id_cliente, saldo) VALUES (?, ?)', [userId, credits]);
        print('Carteira criada no MySQL para usuário $userId com saldo $credits');
      } else {
        // Atualizar saldo existente
        await dbHelper.executeQuery('UPDATE carteiras SET saldo = ? WHERE id_cliente = ?', [credits, userId]);
        print('Saldo atualizado no MySQL para usuário $userId: $credits');
      }
    } catch (e) {
      print('Erro ao definir créditos no MySQL: $e');
    }
  }
  
  static Future<bool> debitCredits(double amount, [int? userId]) async {
    if (userId == null) return false;
    
    try {
      final currentCredits = await getCredits(userId);
      
      if (currentCredits >= amount && amount > 0) {
        final newBalance = currentCredits - amount;
        
        // Atualizar saldo no MySQL
        await dbHelper.executeQuery('UPDATE carteiras SET saldo = ? WHERE id_cliente = ?', [newBalance, userId]);
        
        // Registrar transação
        final carteiraResult = await dbHelper.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
        if (carteiraResult.isNotEmpty) {
          final carteiraId = carteiraResult.first['id'];
          await dbHelper.executeQuery(
            'INSERT INTO transacoes (id_carteira, valor, tipo) VALUES (?, ?, ?)',
            [carteiraId, amount, 'debito']
          );
        }
        
        print('Débito realizado no MySQL! Novo saldo: $newBalance');
        return true;
      }
      
      print('Saldo insuficiente para débito');
      return false;
    } catch (e) {
      print('Erro ao debitar créditos no MySQL: $e');
      return false;
    }
  }
  
  static Future<void> addCredits(double amount, [int? userId]) async {
    if (userId == null) return;
    
    try {
      final currentCredits = await getCredits(userId);
      final newBalance = currentCredits + amount;
      
      // Verificar se carteira existe, senão criar
      final existingWallet = await dbHelper.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
      if (existingWallet.isEmpty) {
        await dbHelper.executeQuery('INSERT INTO carteiras (id_cliente, saldo) VALUES (?, ?)', [userId, newBalance]);
      } else {
        await dbHelper.executeQuery('UPDATE carteiras SET saldo = ? WHERE id_cliente = ?', [newBalance, userId]);
      }
      
      // Registrar transação
      final carteiraResult = await dbHelper.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
      if (carteiraResult.isNotEmpty) {
        final carteiraId = carteiraResult.first['id'];
        await dbHelper.executeQuery(
          'INSERT INTO transacoes (id_carteira, valor, tipo) VALUES (?, ?, ?)',
          [carteiraId, amount, 'credito']
        );
      }
      
      print('Créditos adicionados no MySQL: $newBalance');
    } catch (e) {
      print('Erro ao adicionar créditos no MySQL: $e');
    }
  }
  
  static Future<void> resetCredits([int? userId]) async {
    if (userId == null) return;
    await setCredits(0.0, userId);
  }
}