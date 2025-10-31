import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserService {
  final String token;

  UserService({required this.token});

  // Buscar perfil do usuário
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/profile'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar perfil');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Atualizar perfil
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/profile'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao atualizar perfil');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar saldo de créditos
  Future<double> getCreditsBalance() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.credits}/balance'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['balance'].toDouble();
      } else {
        throw Exception('Erro ao buscar saldo');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Adicionar créditos
  Future<Map<String, dynamic>> addCredits(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.credits}/add'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao adicionar créditos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
