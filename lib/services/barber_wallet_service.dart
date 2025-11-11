import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_manager.dart';

class BarberWalletService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> getWalletInfo(int barberId) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/barbeiro/$barberId/carteira'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar carteira: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboard(int barberId) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/barbeiro/$barberId/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<bool> makeDeposit(int barberId, double amount, String description) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/barbeiro/$barberId/deposito'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'valor': amount,
          'descricao': description,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erro ao fazer depósito: $e');
    }
  }

  Future<bool> makeWithdrawal(int barberId, double amount, String type, String description) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/barbeiro/$barberId/saque'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'valor': amount,
          'tipo_saque': type,
          'descricao': description,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erro ao fazer saque: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(int barberId, {int limit = 20, int offset = 0}) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/barbeiro/$barberId/transacoes?limite=$limit&offset=$offset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['transacoes'] ?? []);
      } else {
        throw Exception('Erro ao carregar histórico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthlyReport(int barberId, int month, int year) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/barbeiro/$barberId/relatorio/$year/$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao carregar relatório: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}