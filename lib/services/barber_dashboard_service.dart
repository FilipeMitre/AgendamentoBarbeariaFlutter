import '../database/database_helper.dart';

class BarberDashboardService {
  static final dbHelper = DatabaseHelper.instance;

  // Buscar agendamentos de hoje do barbeiro
  Future<List<Map<String, dynamic>>> getTodayAppointments(int barberId) async {
    try {
      final result = await dbHelper.query('''
        SELECT 
          a.id,
          u.nome as cliente_nome,
          s.nome as servico_nome,
          a.data_hora_agendamento,
          a.status,
          s.duracao_minutos,
          s.preco_creditos
        FROM agendamentos a
        INNER JOIN usuarios u ON a.id_cliente = u.id
        INNER JOIN servicos s ON a.id_servico = s.id
        WHERE a.id_barbeiro = ? 
        AND DATE(a.data_hora_agendamento) = CURDATE()
        AND a.status IN ('confirmado', 'pendente')
        ORDER BY a.data_hora_agendamento ASC
      ''', [barberId]);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Erro ao buscar agendamentos de hoje: $e');
      return [];
    }
  }

  // Buscar próximos agendamentos do barbeiro
  Future<List<Map<String, dynamic>>> getUpcomingAppointments(int barberId) async {
    try {
      final result = await dbHelper.query('''
        SELECT 
          a.id,
          u.nome as cliente_nome,
          s.nome as servico_nome,
          a.data_hora_agendamento,
          a.status,
          s.duracao_minutos,
          s.preco_creditos
        FROM agendamentos a
        INNER JOIN usuarios u ON a.id_cliente = u.id
        INNER JOIN servicos s ON a.id_servico = s.id
        WHERE a.id_barbeiro = ? AND a.status = 'confirmado'
        AND a.data_hora_agendamento >= NOW()
        ORDER BY a.data_hora_agendamento ASC
        LIMIT 5
      ''', [barberId]);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Erro ao buscar próximos agendamentos: $e');
      return [];
    }
  }

  // Buscar agendamentos por data
  Future<List<Map<String, dynamic>>> getAppointmentsByDate(int barberId, DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final result = await dbHelper.query('''
        SELECT 
          a.id,
          u.nome as cliente_nome,
          s.nome as servico_nome,
          a.data_hora_agendamento,
          a.status,
          s.duracao_minutos,
          s.preco_creditos
        FROM agendamentos a
        INNER JOIN usuarios u ON a.id_cliente = u.id
        INNER JOIN servicos s ON a.id_servico = s.id
        WHERE a.id_barbeiro = ? 
        AND DATE(a.data_hora_agendamento) = ?
        AND a.status IN ('confirmado', 'pendente')
        ORDER BY a.data_hora_agendamento ASC
      ''', [barberId, dateStr]);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Erro ao buscar agendamentos por data: $e');
      return [];
    }
  }

  // Buscar todos os agendamentos do barbeiro
  Future<List<Map<String, dynamic>>> getBarberAppointments(int barberId) async {
    try {
      final result = await dbHelper.query('''
        SELECT 
          a.id,
          a.data_hora_agendamento,
          a.status,
          u.nome as cliente_nome,
          u.email as cliente_email,
          s.nome as servico_nome,
          s.duracao_minutos,
          s.preco_creditos
        FROM agendamentos a
        JOIN usuarios u ON a.id_cliente = u.id
        JOIN servicos s ON a.id_servico = s.id
        WHERE a.id_barbeiro = ?
        ORDER BY a.data_hora_agendamento DESC
      ''', [barberId]);

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Erro ao buscar agendamentos do barbeiro: $e');
      return [];
    }
  }

  // Atualizar status do agendamento
  Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      await dbHelper.executeQuery(
        'UPDATE agendamentos SET status = ? WHERE id = ?',
        [status, appointmentId]
      );
      return true;
    } catch (e) {
      print('Erro ao atualizar status do agendamento: $e');
      return false;
    }
  }

  // Cancelar agendamento
  Future<bool> cancelAppointment(int appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'cancelado');
  }

  // Concluir agendamento
  Future<bool> completeAppointment(int appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'concluido');
  }

  // Buscar estatísticas do barbeiro
  Future<Map<String, dynamic>> getBarberStats(int barberId) async {
    try {
      final result = await dbHelper.query('''
        SELECT 
          (SELECT COUNT(*) FROM agendamentos WHERE id_barbeiro = ? AND status = 'confirmado') as agendamentos_confirmados,
          (SELECT COUNT(*) FROM agendamentos WHERE id_barbeiro = ? AND status = 'concluido') as agendamentos_concluidos,
          (SELECT COUNT(*) FROM servicos WHERE id_barbeiro = ?) as total_servicos,
          (SELECT COALESCE(SUM(s.preco_creditos), 0) FROM servicos s 
           INNER JOIN agendamentos a ON s.id = a.id_servico 
           WHERE a.id_barbeiro = ? AND a.status = 'concluido') as receita_total
      ''', [barberId, barberId, barberId, barberId]);

      if (result.isNotEmpty) {
        final data = result.first;
        return {
          'agendamentos_confirmados': data['agendamentos_confirmados'] ?? 0,
          'agendamentos_concluidos': data['agendamentos_concluidos'] ?? 0,
          'total_servicos': data['total_servicos'] ?? 0,
          'receita_total': data['receita_total'] ?? 0.0,
        };
      }
      return {
        'agendamentos_confirmados': 0,
        'agendamentos_concluidos': 0,
        'total_servicos': 0,
        'receita_total': 0.0,
      };
    } catch (e) {
      print('Erro ao buscar estatísticas do barbeiro: $e');
      return {
        'agendamentos_confirmados': 0,
        'agendamentos_concluidos': 0,
        'total_servicos': 0,
        'receita_total': 0.0,
      };
    }
  }

  // Buscar clientes para agendamento
  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final result = await dbHelper.query(
        'SELECT id, nome as name, email FROM usuarios WHERE papel = ? ORDER BY nome',
        ['cliente']
      );
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Erro ao buscar clientes: $e');
      return [];
    }
  }

  // Criar agendamento como barbeiro
  Future<bool> createAppointment({
    required int clientId,
    required int barberId,
    required int serviceId,
    required String dateTime,
    String? notes,
  }) async {
    try {
      await dbHelper.executeQuery('''
        INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
        VALUES (?, ?, ?, ?, 'confirmado')
      ''', [clientId, barberId, serviceId, dateTime]);
      return true;
    } catch (e) {
      print('Erro ao criar agendamento: $e');
      return false;
    }
  }
}