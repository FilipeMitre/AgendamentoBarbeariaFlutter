import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String baseUrl = 'http://localhost:3001/api';

  DatabaseHelper._init();

  // Método para executar queries via API
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? params]) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sql': sql, 'params': params ?? []}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na query via API: $e');
      return [];
    }
  }

  // Método para queries que retornam insertId/affectedRows
  Future<Map<String, dynamic>> executeQuery(String sql, [List<dynamic>? params]) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sql': sql, 'params': params ?? []}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return Map<String, dynamic>.from(results.first);
        }
        return {};
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na query via API: $e');
      rethrow;
    }
  }
}