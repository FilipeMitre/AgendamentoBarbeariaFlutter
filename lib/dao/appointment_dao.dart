import '../database/database_helper.dart';
import '../models/appointment_model.dart';

class AppointmentDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar agendamento
  Future<int> create(AppointmentModel appointment) async {
    try {
      final results = await dbHelper.executeQuery(
        'INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status, observacoes) VALUES (?, ?, ?, ?, ?, ?)',
        [
          appointment.userId, 
          appointment.barberId, 
          appointment.serviceId, 
          '${appointment.appointmentDate} ${appointment.appointmentTime}', 
          appointment.status, 
          appointment.notes
        ]
      );
      return results.insertId ?? 0;
    } catch (e) {
      print('Erro ao criar agendamento: $e');
      return 0;
    }
  }

  // Buscar agendamento por ID
  Future<AppointmentModel?> getById(int id) async {
    try {
      final result = await dbHelper.query('SELECT * FROM agendamentos WHERE id = ?', [id]);
      
      if (result.isNotEmpty) {
        final row = result.first;
        final dateTime = row['data_hora_agendamento'].toString().split(' ');
        return AppointmentModel(
          id: row['id'],
          userId: row['id_cliente'],
          barbershopId: 1, // Default
          barberId: row['id_barbeiro'],
          serviceId: row['id_servico'],
          appointmentDate: dateTime.isNotEmpty ? dateTime[0] : '',
          appointmentTime: dateTime.length > 1 ? dateTime[1] : '',
          status: row['status'],
          totalPrice: 0.0, // Default
          notes: row['observacoes'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar agendamento: $e');
      return null;
    }
  }

  // Listar agendamentos de um cliente
  Future<List<AppointmentModel>> getByClientId(int clientId) async {
    try {
      final result = await dbHelper.query(
        'SELECT * FROM agendamentos WHERE id_cliente = ? ORDER BY data_hora_agendamento DESC',
        [clientId]
      );
      
      return result.map((row) {
        final dateTime = row['data_hora_agendamento'].toString().split(' ');
        return AppointmentModel(
          id: row['id'],
          userId: row['id_cliente'],
          barbershopId: 1, // Default
          barberId: row['id_barbeiro'],
          serviceId: row['id_servico'],
          appointmentDate: dateTime.isNotEmpty ? dateTime[0] : '',
          appointmentTime: dateTime.length > 1 ? dateTime[1] : '',
          status: row['status'],
          totalPrice: 0.0, // Default
          notes: row['observacoes'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar agendamentos do cliente: $e');
      return [];
    }
  }

  // Atualizar status do agendamento
  Future<int> updateStatus(int id, String status) async {
    try {
      final results = await dbHelper.executeQuery(
        'UPDATE agendamentos SET status = ? WHERE id = ?',
        [status, id]
      );
      return results.affectedRows ?? 0;
    } catch (e) {
      print('Erro ao atualizar status do agendamento: $e');
      return 0;
    }
  }

  // Deletar agendamento
  Future<int> delete(int id) async {
    try {
      final results = await dbHelper.executeQuery('DELETE FROM agendamentos WHERE id = ?', [id]);
      return results.affectedRows ?? 0;
    } catch (e) {
      print('Erro ao deletar agendamento: $e');
      return 0;
    }
  }
}