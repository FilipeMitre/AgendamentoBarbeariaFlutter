import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentHistoryService {
  // Buscar agendamentos do usuário por status
  Future<List<Map<String, dynamic>>> getUserAppointments(int userId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sql': '''
            SELECT 
              a.id,
              a.data_hora_agendamento,
              a.status,
              s.nome as servico_nome,
              s.preco_creditos,
              s.duracao_minutos,
              b.nome as barbeiro_nome,
              pb.bio as barbeiro_bio
            FROM agendamentos a
            INNER JOIN servicos s ON a.id_servico = s.id
            INNER JOIN usuarios b ON a.id_barbeiro = b.id
            LEFT JOIN perfis_barbeiros pb ON b.id = pb.id_usuario
            WHERE a.id_cliente = ? AND a.status = ?
            ORDER BY a.data_hora_agendamento DESC
          ''',
          'params': [userId, status]
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

  // Buscar todos os agendamentos do usuário
  Future<Map<String, List<Map<String, dynamic>>>> getAllUserAppointments(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sql': '''
            SELECT 
              a.id,
              a.data_hora_agendamento,
              a.status,
              s.nome as servico_nome,
              s.preco_creditos,
              s.duracao_minutos,
              b.nome as barbeiro_nome,
              pb.bio as barbeiro_bio
            FROM agendamentos a
            INNER JOIN servicos s ON a.id_servico = s.id
            INNER JOIN usuarios b ON a.id_barbeiro = b.id
            LEFT JOIN perfis_barbeiros pb ON b.id = pb.id_usuario
            WHERE a.id_cliente = ?
            ORDER BY a.data_hora_agendamento DESC
          ''',
          'params': [userId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final appointments = List<Map<String, dynamic>>.from(data['results']);
        
        // Separar por status
        final Map<String, List<Map<String, dynamic>>> result = {
          'confirmado': [],
          'concluido': [],
          'cancelado': [],
        };
        
        for (final appointment in appointments) {
          final status = appointment['status'];
          if (result.containsKey(status)) {
            result[status]!.add(appointment);
          }
        }
        
        return result;
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
        Uri.parse('http://localhost:3001/api/query'),
        headers: {'Content-Type': 'application/json'},
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
}