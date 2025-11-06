import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BarberDashboardService {
  // Buscar estatísticas do barbeiro
  Future<Map<String, dynamic>> getBarberStats(int barberId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              (SELECT COUNT(*) FROM agendamentos WHERE id_barbeiro = ? AND status = 'confirmado') as agendamentos_confirmados,
              (SELECT COUNT(*) FROM agendamentos WHERE id_barbeiro = ? AND status = 'concluido') as agendamentos_concluidos,
              (SELECT COUNT(*) FROM servicos WHERE id_barbeiro = ?) as total_servicos,
              (SELECT COALESCE(SUM(s.preco_creditos), 0) FROM servicos s 
               INNER JOIN agendamentos a ON s.id = a.id_servico 
               WHERE a.id_barbeiro = ? AND a.status = 'concluido') as receita_total
          ''',
          'params': [barberId, barberId, barberId, barberId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['results'][0];
        return {
          'agendamentos_confirmados': result['agendamentos_confirmados'] ?? 0,
          'agendamentos_concluidos': result['agendamentos_concluidos'] ?? 0,
          'total_servicos': result['total_servicos'] ?? 0,
          'receita_total': result['receita_total'] ?? 0.0,
        };
      } else {
        throw Exception('Erro ao buscar estatísticas do barbeiro');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar próximos agendamentos do barbeiro
  Future<List<Map<String, dynamic>>> getUpcomingAppointments(int barberId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
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
          ''',
          'params': [barberId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar agendamentos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar agendamentos de hoje do barbeiro
  Future<List<Map<String, dynamic>>> getTodayAppointments(int barberId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
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
          ''',
          'params': [barberId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar agendamentos de hoje');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar agendamentos por data
  Future<List<Map<String, dynamic>>> getAppointmentsByDate(int barberId, DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
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
          ''',
          'params': [barberId, '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar agendamentos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Cancelar agendamento
  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'UPDATE agendamentos SET status = ? WHERE id = ?',
          'params': ['cancelado', appointmentId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao cancelar agendamento');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Concluir agendamento
  Future<bool> completeAppointment(int appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'UPDATE agendamentos SET status = ? WHERE id = ?',
          'params': ['concluido', appointmentId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao concluir agendamento');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar todos os agendamentos do barbeiro (compatibilidade com BarberService)
  Future<List<Map<String, dynamic>>> getBarberAppointments(int barberId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              a.id,
              a.data_hora_agendamento,
              a.status,
              a.observacoes,
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
          ''',
          'params': [barberId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar agendamentos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Atualizar status do agendamento (compatibilidade com BarberService)
  Future<bool> updateAppointmentStatus(int appointmentId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'UPDATE agendamentos SET status = ? WHERE id = ?',
          'params': [status, appointmentId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao atualizar agendamento');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Criar agendamento como barbeiro (compatibilidade com BarberService)
  Future<bool> createAppointment({
    required int clientId,
    required int barberId,
    required int serviceId,
    required String dateTime,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, observacoes, status)
            VALUES (?, ?, ?, ?, ?, 'confirmado')
          ''',
          'params': [clientId, barberId, serviceId, dateTime, notes ?? '']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['insertId'] != null;
      } else {
        throw Exception('Erro ao criar agendamento');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar clientes para agendamento (compatibilidade com BarberService)
  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'SELECT id, nome as name, email FROM usuarios WHERE papel = ? ORDER BY nome',
          'params': ['cliente']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar clientes');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}