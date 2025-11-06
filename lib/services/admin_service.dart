import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/user_model.dart';

class AdminService {
  // Listar todos os usuários
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'SELECT id, nome as name, email, cpf, papel as role, criado_em as created_at, atualizado_em as updated_at FROM usuarios ORDER BY nome',
          'params': []
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((user) => UserModel.fromMap({
          ...user,
          'password': '', // Não retornamos a senha
          'credits': 0.0,
        })).toList();
      } else {
        throw Exception('Erro ao buscar usuários');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Transformar cliente em barbeiro
  Future<bool> promoteToBarber(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'UPDATE usuarios SET papel = ? WHERE id = ?',
          'params': ['barbeiro', userId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao promover usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Remover papel de barbeiro (voltar para cliente)
  Future<bool> demoteToClient(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'UPDATE usuarios SET papel = ? WHERE id = ?',
          'params': ['cliente', userId]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'][0]['affectedRows'] > 0;
      } else {
        throw Exception('Erro ao rebaixar usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Listar apenas barbeiros
  Future<List<UserModel>> getBarbers() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/query'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'sql': 'SELECT id, nome as name, email, cpf, papel as role, criado_em as created_at, atualizado_em as updated_at FROM usuarios WHERE papel = ? ORDER BY nome',
          'params': ['barbeiro']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((user) => UserModel.fromMap({
          ...user,
          'password': '',
          'credits': 0.0,
        })).toList();
      } else {
        throw Exception('Erro ao buscar barbeiros');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}