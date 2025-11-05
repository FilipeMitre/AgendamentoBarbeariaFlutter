import '../database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditService {
  static final dbHelper = DatabaseHelper.instance;
  
  static Future<double> getCredits([int? userId]) async {
    if (userId == null) return 0.0;
    
    try {
      // Tentar buscar do banco primeiro
      final db = await dbHelper.database;
      final result = await db.query('SELECT saldo FROM carteiras WHERE id_cliente = ?', [userId]);
      
      if (result.isNotEmpty) {
        final credits = double.parse(result.first['saldo'].toString());
        print('Créditos carregados do banco: $credits para usuário $userId');
        
        // Sincronizar com SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_credits_$userId', credits);
        
        return credits;
      }
    } catch (e) {
      print('Erro ao buscar créditos no banco: $e');
    }
    
    // Fallback para SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final credits = prefs.getDouble('user_credits_$userId') ?? 0.0;
    print('Carregando créditos do SharedPreferences: $credits para usuário $userId');
    return credits;
  }
  
  static Future<void> setCredits(double credits, [int? userId]) async {
    if (userId == null) return;
    
    try {
      final db = await dbHelper.database;
      
      // Verificar se a carteira existe
      final existingWallet = await db.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
      
      if (existingWallet.isEmpty) {
        // Criar carteira se não existir
        await db.query('INSERT INTO carteiras (id_cliente, saldo) VALUES (?, ?)', [userId, credits]);
        print('Carteira criada no banco para usuário $userId com saldo $credits');
      } else {
        // Atualizar saldo existente
        await db.query('UPDATE carteiras SET saldo = ? WHERE id_cliente = ?', [credits, userId]);
        print('Saldo atualizado no banco para usuário $userId: $credits');
      }
    } catch (e) {
      print('Erro ao definir créditos no banco: $e');
    }
    
    // SEMPRE salvar no SharedPreferences como backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_credits_$userId', credits);
    print('Créditos salvos no SharedPreferences: $credits para usuário $userId');
  }
  
  static Future<bool> debitCredits(double amount, [int? userId]) async {
    try {
      if (userId == null) return false;
      
      final currentCredits = await getCredits(userId);
      print('=== DEBUG DEBIT ===');
      print('Saldo atual: $currentCredits');
      print('Valor a debitar: $amount');
      print('Saldo suficiente: ${currentCredits >= amount}');
      
      if (currentCredits >= amount && amount > 0) {
        final newBalance = currentCredits - amount;
        
        try {
          final db = await dbHelper.database;
          
          // Atualizar saldo no banco
          await db.query('UPDATE carteiras SET saldo = ? WHERE id_cliente = ?', [newBalance, userId]);
          
          // Registrar transação
          final carteiraResult = await db.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
          if (carteiraResult.isNotEmpty) {
            final carteiraId = carteiraResult.first['id'];
            await db.query(
              'INSERT INTO transacoes (id_carteira, valor, tipo) VALUES (?, ?, ?)',
              [carteiraId, amount, 'debito']
            );
          }
          
          print('Débito realizado no banco! Novo saldo: $newBalance');
        } catch (e) {
          print('Erro ao debitar no banco: $e');
        }
        
        // SEMPRE salvar no SharedPreferences como backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_credits_$userId', newBalance);
        print('Débito salvo no SharedPreferences: $newBalance');
        
        // Verificar se foi salvo corretamente
        final verifyBalance = await getCredits(userId);
        print('Saldo verificado após débito: $verifyBalance');
        print('===================');
        return true;
      }
      print('ERRO: Saldo insuficiente ou valor inválido');
      print('===================');
      return false;
    } catch (e) {
      print('ERRO ao debitar créditos: $e');
      print('===================');
      return false;
    }
  }
  
  static Future<void> addCredits(double amount, [int? userId]) async {
    if (userId == null) return;
    
    final currentCredits = await getCredits(userId);
    final newBalance = currentCredits + amount;
    print('=== DEBUG ADD ===');
    print('Saldo atual: $currentCredits');
    print('Valor a adicionar: $amount');
    print('Novo saldo: $newBalance');
    
    try {
      final db = await dbHelper.database;
      
      // Verificar se carteira existe, senão criar
      final existingWallet = await db.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
      if (existingWallet.isEmpty) {
        await db.query('INSERT INTO carteiras (id_cliente, saldo) VALUES (?, ?)', [userId, newBalance]);
      } else {
        await db.query('UPDATE carteiras SET saldo = ? WHERE id_cliente = ?', [newBalance, userId]);
      }
      
      // Registrar transação
      final carteiraResult = await db.query('SELECT id FROM carteiras WHERE id_cliente = ?', [userId]);
      if (carteiraResult.isNotEmpty) {
        final carteiraId = carteiraResult.first['id'];
        await db.query(
          'INSERT INTO transacoes (id_carteira, valor, tipo) VALUES (?, ?, ?)',
          [carteiraId, amount, 'credito']
        );
      }
      
      print('Créditos adicionados no banco: $newBalance');
    } catch (e) {
      print('Erro ao adicionar créditos no banco: $e');
    }
    
    // SEMPRE salvar no SharedPreferences como backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_credits_$userId', newBalance);
    print('Créditos salvos no SharedPreferences: $newBalance');
    
    // Verificar se foi salvo
    final verifyBalance = await getCredits(userId);
    print('Saldo verificado após adição: $verifyBalance');
    print('=================');
  }
  
  static Future<void> resetCredits([int? userId]) async {
    if (userId == null) return;
    await setCredits(0.0, userId);
  }
}