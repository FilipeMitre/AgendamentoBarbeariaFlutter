import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/service_model.dart';

class AdminServicesService {
  // Listar todos os serviços com informações do barbeiro
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            SELECT s.id, s.nome, s.duracao_minutos, s.preco_creditos, 
                   s.id_barbeiro, u.nome as barbeiro_nome
            FROM servicos s
            INNER JOIN usuarios u ON s.id_barbeiro = u.id
            WHERE u.papel = 'barbeiro'
            ORDER BY u.nome, s.nome
          ''',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((service) => ServiceModel.fromMap({
          'id': service['id'],
          'name': service['nome'],
          'duration': service['duracao_minutos'],
          'price': service['preco_creditos'],
          'barberId': service['id_barbeiro'],
          'barberName': service['barbeiro_nome'],
        })).toList();
      } else {
        throw Exception('Erro ao buscar serviços');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Adicionar novo serviço
  Future<bool> addService(ServiceModel service) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            INSERT INTO servicos (id_barbeiro, nome, duracao_minutos, preco_creditos)
            VALUES (?, ?, ?, ?)
          ''',
          'params': [
            service.barberId,
            service.name,
            service.duration,
            service.price,
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao adicionar serviço');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Atualizar serviço
  Future<bool> updateService(ServiceModel service) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': '''
            UPDATE servicos 
            SET nome = ?, duracao_minutos = ?, preco_creditos = ?
            WHERE id = ?
          ''',
          'params': [
            service.name,
            service.duration,
            service.price,
            service.id,
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao atualizar serviço');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Excluir serviço
  Future<bool> deleteService(int serviceId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'DELETE FROM servicos WHERE id = ?',
          'params': [serviceId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao excluir serviço');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar barbeiros para o dropdown
  Future<List<Map<String, dynamic>>> getBarbers() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'SELECT id, nome FROM usuarios WHERE papel = ? ORDER BY nome',
          'params': ['barbeiro']
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
}