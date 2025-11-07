import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BarberService {
  // Buscar todos os barbeiros disponíveis
  Future<List<Map<String, dynamic>>> getAvailableBarbers() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sql': '''
            SELECT 
              u.id,
              u.nome,
              pb.bio,
              pb.url_foto,
              COALESCE(AVG(av.nota), 0) as rating,
              COUNT(av.id) as total_avaliacoes
            FROM usuarios u
            LEFT JOIN perfis_barbeiros pb ON u.id = pb.id_usuario
            LEFT JOIN avaliacoes av ON u.id = av.id_barbeiro
            WHERE u.papel = 'barbeiro'
            GROUP BY u.id, u.nome, pb.bio, pb.url_foto
            ORDER BY rating DESC, u.nome ASC
          ''',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar barbeiros');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar serviços de um barbeiro específico
  Future<List<Map<String, dynamic>>> getBarberServices(int barberId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sql': '''
            SELECT 
              id,
              nome,
              duracao_minutos,
              preco_creditos
            FROM servicos
            WHERE id_barbeiro = ?
            ORDER BY preco_creditos ASC
          ''',
          'params': [barberId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar serviços do barbeiro');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar horários disponíveis de um barbeiro em uma data específica
  Future<List<String>> getAvailableTimes(int barberId, DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayOfWeek = _getDayOfWeekInPortuguese(date.weekday);
      
      final response = await http.post(
        Uri.parse('http://localhost:3001/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sql': '''
            SELECT TIME_FORMAT(generated_time, '%H:%i') as horario
            FROM (
              SELECT ADDTIME(h.hora_inicio, SEC_TO_TIME(slot.slot_number * 30 * 60)) as generated_time
              FROM horarios h
              CROSS JOIN (
                SELECT 0 as slot_number UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18
              ) slot
              WHERE h.id_barbeiro = ?
              AND h.dia_da_semana = ?
              AND ADDTIME(h.hora_inicio, SEC_TO_TIME(slot.slot_number * 30 * 60)) < h.hora_fim
            ) times
            WHERE NOT EXISTS (
              SELECT 1 FROM agendamentos a
              WHERE a.id_barbeiro = ?
              AND DATE(a.data_hora_agendamento) = ?
              AND TIME(a.data_hora_agendamento) = TIME(generated_time)
              AND a.status IN ('confirmado', 'pendente')
            )
            AND NOT EXISTS (
              SELECT 1 FROM bloqueios b
              WHERE b.id_barbeiro = ?
              AND ? BETWEEN DATE(b.inicio_bloqueio) AND DATE(b.fim_bloqueio)
              AND TIME(generated_time) BETWEEN TIME(b.inicio_bloqueio) AND TIME(b.fim_bloqueio)
            )
            ORDER BY generated_time ASC
          ''',
          'params': [barberId, dayOfWeek, barberId, dateStr, barberId, dateStr]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'].map<String>((row) => row['horario'].toString()).toList();
      } else {
        throw Exception('Erro ao buscar horários disponíveis');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  String _getDayOfWeekInPortuguese(int weekday) {
    switch (weekday) {
      case 1: return 'Segunda-feira';
      case 2: return 'Terça-feira';
      case 3: return 'Quarta-feira';
      case 4: return 'Quinta-feira';
      case 5: return 'Sexta-feira';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return 'Segunda-feira';
    }
  }
}