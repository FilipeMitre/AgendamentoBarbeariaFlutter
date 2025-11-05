import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String baseUrl = 'http://localhost:3001/api';

  DatabaseHelper._init();

  // Simula uma conexão para manter compatibilidade
  Future<DatabaseHelper> get database async {
    return this;
  }

  // Método genérico para executar queries via API
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
        throw Exception('Erro na consulta: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na query: $e');
      return [];
    }
  }

  Future<void> close() async {
    // Não há conexão para fechar
  }
}
