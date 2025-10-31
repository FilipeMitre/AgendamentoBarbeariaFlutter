import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AppointmentService {
  final String token;

  AppointmentService({required this.token});

  // Criar agendamento
  Future<Map<String, dynamic>> createAppointment({
    required String barbershopId,
    required String barberId,
    required String serviceId,
    required DateTime date,
    required String time,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.appointments}'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'barbershop_id': barbershopId,
          'barber_id': barberId,
          'service_id': serviceId,
          'date': date.toIso8601String(),
          'time': time,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar agendamento');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Listar agendamentos do usuário
  Future<List<Map<String, dynamic>>> getUserAppointments({
    String? status, // 'active', 'completed', 'cancelled'
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.appointments}';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar agendamentos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Cancelar agendamento
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.appointments}/$appointmentId/cancel',
        ),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao cancelar agendamento');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Buscar horários disponíveis
  Future<List<String>> getAvailableTimes({
    required String barberId,
    required DateTime date,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.appointments}/available-times?barber_id=$barberId&date=${date.toIso8601String()}',
        ),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Erro ao buscar horários');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
