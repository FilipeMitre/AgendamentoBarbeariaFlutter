import '../database/database_helper.dart';

class BarberWalletService {
  static final dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getWalletInfo(int barberId) async {
    try {
      final result = await dbHelper.query('''
        SELECT 
          saldo,
          receita_servicos,
          (saldo + receita_servicos) as total_disponivel
        FROM carteiras 
        WHERE id_usuario = ? AND tipo_usuario = "barbeiro"
      ''', [barberId]);

      if (result.isNotEmpty) {
        final data = result.first;
        return {
          'saldo_depositos': double.parse(data['saldo'].toString()),
          'receita_servicos': double.parse(data['receita_servicos'].toString()),
          'total_disponivel': double.parse(data['total_disponivel'].toString()),
        };
      } else {
        // Criar carteira se não existir
        await dbHelper.executeQuery(
          'INSERT INTO carteiras (id_usuario, tipo_usuario, saldo, receita_servicos) VALUES (?, "barbeiro", 0.00, 0.00)',
          [barberId]
        );
        return {
          'saldo_depositos': 0.0,
          'receita_servicos': 0.0,
          'total_disponivel': 0.0,
        };
      }
    } catch (e) {
      print('Erro ao carregar carteira: $e');
      throw Exception('Erro ao carregar carteira: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboard(int barberId) async {
    try {
      final walletInfo = await getWalletInfo(barberId);
      
      // Buscar estatísticas adicionais
      final statsResult = await dbHelper.query('''
        SELECT 
          COUNT(CASE WHEN a.status = 'concluido' AND DATE(a.data_hora_agendamento) >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as servicos_mes,
          COALESCE(SUM(CASE WHEN t.categoria = 'receita_servico' AND t.criado_em >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN t.valor ELSE 0 END), 0) as receita_mes,
          COALESCE(SUM(CASE WHEN t.categoria = 'deposito' AND t.criado_em >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN t.valor ELSE 0 END), 0) as depositos_mes
        FROM usuarios u
        JOIN carteiras c ON u.id = c.id_usuario AND c.tipo_usuario = 'barbeiro'
        LEFT JOIN agendamentos a ON u.id = a.id_barbeiro
        LEFT JOIN transacoes t ON c.id = t.id_carteira
        WHERE u.id = ?
      ''', [barberId]);

      if (statsResult.isNotEmpty) {
        final stats = statsResult.first;
        walletInfo['servicos_concluidos_mes'] = stats['servicos_mes'] ?? 0;
        walletInfo['receita_mes'] = double.parse(stats['receita_mes'].toString());
        walletInfo['depositos_mes'] = double.parse(stats['depositos_mes'].toString());
      }

      return walletInfo;
    } catch (e) {
      print('Erro ao carregar dashboard: $e');
      throw Exception('Erro ao carregar dashboard: $e');
    }
  }

  Future<bool> makeDeposit(int barberId, double amount, String description) async {
    try {
      // Verificar se carteira existe
      final walletResult = await dbHelper.query(
        'SELECT id FROM carteiras WHERE id_usuario = ? AND tipo_usuario = "barbeiro"',
        [barberId]
      );

      int walletId;
      if (walletResult.isEmpty) {
        // Criar carteira se não existir
        await dbHelper.executeQuery(
          'INSERT INTO carteiras (id_usuario, tipo_usuario, saldo, receita_servicos) VALUES (?, "barbeiro", ?, 0.00)',
          [barberId, amount]
        );
        
        final newWalletResult = await dbHelper.query(
          'SELECT id FROM carteiras WHERE id_usuario = ? AND tipo_usuario = "barbeiro"',
          [barberId]
        );
        walletId = newWalletResult.first['id'];
      } else {
        walletId = walletResult.first['id'];
        // Atualizar saldo
        await dbHelper.executeQuery(
          'UPDATE carteiras SET saldo = saldo + ? WHERE id = ?',
          [amount, walletId]
        );
      }

      // Registrar transação
      await dbHelper.executeQuery(
        'INSERT INTO transacoes (id_carteira, valor, tipo, categoria, descricao) VALUES (?, ?, "credito", "deposito", ?)',
        [walletId, amount, description]
      );

      return true;
    } catch (e) {
      print('Erro ao fazer depósito: $e');
      throw Exception('Erro ao fazer depósito: $e');
    }
  }

  Future<bool> makeWithdrawal(int barberId, double amount, String type, String description) async {
    try {
      final walletResult = await dbHelper.query(
        'SELECT id, saldo, receita_servicos FROM carteiras WHERE id_usuario = ? AND tipo_usuario = "barbeiro"',
        [barberId]
      );

      if (walletResult.isEmpty) {
        throw Exception('Carteira não encontrada');
      }

      final wallet = walletResult.first;
      final walletId = wallet['id'];
      final currentBalance = double.parse(wallet['saldo'].toString());
      final currentRevenue = double.parse(wallet['receita_servicos'].toString());

      double balanceToWithdraw = 0;
      double revenueToWithdraw = 0;

      // Calcular valores baseado no tipo de saque
      if (type == 'saldo') {
        if (currentBalance < amount) {
          throw Exception('Saldo insuficiente');
        }
        balanceToWithdraw = amount;
      } else if (type == 'receita') {
        if (currentRevenue < amount) {
          throw Exception('Receita insuficiente');
        }
        revenueToWithdraw = amount;
      } else if (type == 'ambos') {
        if ((currentBalance + currentRevenue) < amount) {
          throw Exception('Fundos insuficientes');
        }
        
        if (currentRevenue >= amount) {
          revenueToWithdraw = amount;
        } else {
          revenueToWithdraw = currentRevenue;
          balanceToWithdraw = amount - currentRevenue;
        }
      }

      // Atualizar carteira
      await dbHelper.executeQuery(
        'UPDATE carteiras SET saldo = saldo - ?, receita_servicos = receita_servicos - ? WHERE id = ?',
        [balanceToWithdraw, revenueToWithdraw, walletId]
      );

      // Registrar transação
      await dbHelper.executeQuery(
        'INSERT INTO transacoes (id_carteira, valor, tipo, categoria, descricao) VALUES (?, ?, "debito", "saque", ?)',
        [walletId, amount, description]
      );

      return true;
    } catch (e) {
      print('Erro ao fazer saque: $e');
      throw Exception('Erro ao fazer saque: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(int barberId, {int limit = 20, int offset = 0}) async {
    try {
      final result = await dbHelper.query('''
        SELECT 
          t.id as id_transacao,
          t.valor,
          t.tipo,
          t.categoria,
          t.descricao,
          t.criado_em,
          CASE 
            WHEN t.categoria = 'deposito' THEN 'Depósito'
            WHEN t.categoria = 'receita_servico' THEN 'Receita de Serviço'
            WHEN t.categoria = 'saque' THEN 'Saque'
            ELSE 'Outros'
          END as tipo_operacao,
          s.nome as nome_servico
        FROM carteiras c
        JOIN transacoes t ON c.id = t.id_carteira
        LEFT JOIN agendamentos a ON t.id_agendamento = a.id
        LEFT JOIN servicos s ON a.id_servico = s.id
        WHERE c.id_usuario = ? AND c.tipo_usuario = 'barbeiro'
        ORDER BY t.criado_em DESC
        LIMIT ? OFFSET ?
      ''', [barberId, limit, offset]);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      throw Exception('Erro ao carregar histórico: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthlyReport(int barberId, int month, int year) async {
    try {
      final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
      final endDate = DateTime(year, month + 1, 0);
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final result = await dbHelper.query('''
        SELECT 
          COUNT(DISTINCT a.id) as servicos_realizados,
          COALESCE(SUM(CASE WHEN t.categoria = 'receita_servico' THEN t.valor ELSE 0 END), 0) as receita_total,
          COALESCE(SUM(CASE WHEN t.categoria = 'deposito' THEN t.valor ELSE 0 END), 0) as depositos_total,
          COALESCE(SUM(CASE WHEN t.categoria = 'saque' THEN t.valor ELSE 0 END), 0) as saques_total
        FROM usuarios u
        JOIN carteiras c ON u.id = c.id_usuario AND c.tipo_usuario = 'barbeiro'
        LEFT JOIN transacoes t ON c.id = t.id_carteira AND DATE(t.criado_em) BETWEEN ? AND ?
        LEFT JOIN agendamentos a ON u.id = a.id_barbeiro AND a.status = 'concluido' AND DATE(a.data_hora_agendamento) BETWEEN ? AND ?
        WHERE u.id = ?
      ''', [startDate, endDateStr, startDate, endDateStr, barberId]);

      if (result.isNotEmpty) {
        return Map<String, dynamic>.from(result.first);
      }
      return {
        'servicos_realizados': 0,
        'receita_total': 0.0,
        'depositos_total': 0.0,
        'saques_total': 0.0,
      };
    } catch (e) {
      print('Erro ao carregar relatório mensal: $e');
      throw Exception('Erro ao carregar relatório mensal: $e');
    }
  }
}