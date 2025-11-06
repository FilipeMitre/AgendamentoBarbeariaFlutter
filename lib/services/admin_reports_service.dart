import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AdminReportsService {
  // Buscar dados gerais dos relatórios
  Future<Map<String, dynamic>> getReportsData() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              (SELECT COALESCE(SUM(s.preco_creditos), 0) FROM servicos s 
               INNER JOIN agendamentos a ON s.id = a.id_servico 
               WHERE a.status = 'concluido' AND a.data_hora_agendamento >= DATE_SUB(NOW(), INTERVAL 30 DAY)) as receita_total,
              
              (SELECT COUNT(*) FROM agendamentos 
               WHERE data_hora_agendamento >= DATE_SUB(NOW(), INTERVAL 30 DAY)) as total_agendamentos,
              
              (SELECT COUNT(*) FROM agendamentos 
               WHERE status = 'cancelado' AND data_hora_agendamento >= DATE_SUB(NOW(), INTERVAL 30 DAY)) as agendamentos_cancelados,
              
              (SELECT COALESCE(SUM(preco_total), 0) FROM vendas_produtos 
               WHERE data_venda >= DATE_SUB(NOW(), INTERVAL 30 DAY)) as vendas_produtos,
              
              (SELECT COUNT(*) FROM vendas_produtos 
               WHERE data_venda >= DATE_SUB(NOW(), INTERVAL 30 DAY)) as quantidade_produtos
          ''',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['results'][0];
        
        final totalAgendamentos = result['total_agendamentos'] ?? 0;
        final agendamentosCancelados = result['agendamentos_cancelados'] ?? 0;
        final taxaCancelamento = totalAgendamentos > 0 
            ? (agendamentosCancelados / totalAgendamentos * 100) 
            : 0.0;

        return {
          'receita_total': result['receita_total'] ?? 0.0,
          'total_agendamentos': totalAgendamentos,
          'taxa_cancelamento': taxaCancelamento,
          'vendas_produtos': result['vendas_produtos'] ?? 0.0,
          'quantidade_produtos': result['quantidade_produtos'] ?? 0,
        };
      } else {
        throw Exception('Erro ao buscar dados dos relatórios');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar top barbeiros por receita
  Future<List<Map<String, dynamic>>> getTopBarbers() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              u.nome as barbeiro_nome,
              COUNT(a.id) as total_atendimentos,
              COALESCE(SUM(s.preco_creditos), 0) as receita_total
            FROM usuarios u
            INNER JOIN agendamentos a ON u.id = a.id_barbeiro
            INNER JOIN servicos s ON a.id_servico = s.id
            WHERE u.papel = 'barbeiro' 
              AND a.status = 'concluido'
              AND a.data_hora_agendamento >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY u.id, u.nome
            ORDER BY receita_total DESC
            LIMIT 5
          ''',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        throw Exception('Erro ao buscar top barbeiros');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar dados de comparação com período anterior
  Future<Map<String, dynamic>> getComparisonData() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT 
              (SELECT COALESCE(SUM(s.preco_creditos), 0) FROM servicos s 
               INNER JOIN agendamentos a ON s.id = a.id_servico 
               WHERE a.status = 'concluido' 
               AND a.data_hora_agendamento >= DATE_SUB(NOW(), INTERVAL 60 DAY)
               AND a.data_hora_agendamento < DATE_SUB(NOW(), INTERVAL 30 DAY)) as receita_anterior,
              
              (SELECT COUNT(*) FROM agendamentos 
               WHERE data_hora_agendamento >= DATE_SUB(NOW(), INTERVAL 60 DAY)
               AND data_hora_agendamento < DATE_SUB(NOW(), INTERVAL 30 DAY)) as agendamentos_anterior
          ''',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['results'][0];
        return {
          'receita_anterior': result['receita_anterior'] ?? 0.0,
          'agendamentos_anterior': result['agendamentos_anterior'] ?? 0,
        };
      } else {
        throw Exception('Erro ao buscar dados de comparação');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}