import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class DashboardService {
  // Buscar estatísticas gerais do dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              (SELECT COUNT(*) FROM usuarios WHERE papel = 'cliente') as total_usuarios,
              (SELECT COUNT(*) FROM usuarios WHERE papel = 'barbeiro') as total_barbeiros,
              (SELECT COUNT(*) FROM agendamentos WHERE status = 'confirmado') as total_agendamentos,
              (SELECT COALESCE(SUM(preco_creditos), 0) FROM servicos s 
               INNER JOIN agendamentos a ON s.id = a.id_servico 
               WHERE a.status = 'concluido') as receita_total
          ''',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['results'][0];
        return {
          'usuarios': result['total_usuarios'] ?? 0,
          'barbeiros': result['total_barbeiros'] ?? 0,
          'agendamentos': result['total_agendamentos'] ?? 0,
          'receita': result['receita_total'] ?? 0.0,
        };
      } else {
        throw Exception('Erro ao buscar estatísticas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar agendamentos recentes
  Future<List<Map<String, dynamic>>> getRecentAppointments() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              a.id,
              u_cliente.nome as cliente_nome,
              u_barbeiro.nome as barbeiro_nome,
              s.nome as servico_nome,
              a.data_hora_agendamento,
              a.status
            FROM agendamentos a
            INNER JOIN usuarios u_cliente ON a.id_cliente = u_cliente.id
            INNER JOIN usuarios u_barbeiro ON a.id_barbeiro = u_barbeiro.id
            INNER JOIN servicos s ON a.id_servico = s.id
            ORDER BY a.data_hora_agendamento DESC
            LIMIT 5
          ''',
          'params': []
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
}