import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/login'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao fazer login');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Cadastro
  Future<Map<String, dynamic>> register({
    required String name,
    required String cpf,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/register'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'name': name,
          'cpf': cpf,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao cadastrar');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Recuperar senha
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}/forgot-password'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao recuperar senha');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
