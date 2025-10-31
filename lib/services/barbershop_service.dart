import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class BarbershopService {
  final String token;

  BarbershopService({required this.token});

  // Listar barbearias
  Future<List<Map<String, dynamic>>> getBarbershops({
    double? latitude,
    double? longitude,
    double? radius, // em km
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.barbershops}';

      if (latitude != null && longitude != null) {
        url += '?lat=$latitude&lng=$longitude';
        if (radius != null) {
          url += '&radius=$radius';
        }
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar barbearias');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Detalhes de uma barbearia
  Future<Map<String, dynamic>> getBarbershopDetails(String barbershopId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.barbershops}/$barbershopId'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar detalhes');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Listar barbeiros de uma barbearia
  Future<List<Map<String, dynamic>>> getBarbers(String barbershopId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.barbershops}/$barbershopId/barbers',
        ),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar barbeiros');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
