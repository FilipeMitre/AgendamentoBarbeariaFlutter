import '../database/database_helper.dart';
import '../models/appointment_model.dart';

class AppointmentDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar agendamento
  Future<int> create(AppointmentModel appointment) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status) VALUES (?, ?, ?, ?, ?)',
      [appointment.userId, appointment.barberId, appointment.serviceId, 
       '${appointment.appointmentDate} ${appointment.appointmentTime}', appointment.status]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Buscar agendamento por ID
  Future<AppointmentModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM agendamentos WHERE id = ?', [id]);
    
    if (result.isNotEmpty) {
      final row = result.first;
      final dateTime = DateTime.parse(row['data_hora_agendamento'].toString());
      return AppointmentModel(
        id: row['id'],
        userId: row['id_cliente'],
        barbershopId: 1, // Valor padrão
        barberId: row['id_barbeiro'],
        serviceId: row['id_servico'],
        appointmentDate: dateTime.toIso8601String().split('T')[0],
        appointmentTime: '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        status: row['status'],
        totalPrice: 0.0, // Buscar da tabela servicos se necessário
        paymentMethod: 'credits',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
    return null;
  }

  // Listar agendamentos de um usuário
  Future<List<AppointmentModel>> getByUserId(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT * FROM agendamentos WHERE id_cliente = ? ORDER BY data_hora_agendamento DESC',
      [userId]
    );
    
    return result.map((row) {
      final dateTime = DateTime.parse(row['data_hora_agendamento'].toString());
      return AppointmentModel(
        id: row['id'],
        userId: row['id_cliente'],
        barbershopId: 1,
        barberId: row['id_barbeiro'],
        serviceId: row['id_servico'],
        appointmentDate: dateTime.toIso8601String().split('T')[0],
        appointmentTime: '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        status: row['status'],
        totalPrice: 0.0,
        paymentMethod: 'credits',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }).toList();
  }

  // Listar agendamentos por status
  Future<List<AppointmentModel>> getByStatus(int userId, String status) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT * FROM agendamentos WHERE id_cliente = ? AND status = ? ORDER BY data_hora_agendamento DESC',
      [userId, status]
    );
    
    return result.map((row) {
      final dateTime = DateTime.parse(row['data_hora_agendamento'].toString());
      return AppointmentModel(
        id: row['id'],
        userId: row['id_cliente'],
        barbershopId: 1,
        barberId: row['id_barbeiro'],
        serviceId: row['id_servico'],
        appointmentDate: dateTime.toIso8601String().split('T')[0],
        appointmentTime: '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        status: row['status'],
        totalPrice: 0.0,
        paymentMethod: 'credits',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }).toList();
  }

  // Atualizar agendamento
  Future<int> update(AppointmentModel appointment) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'UPDATE agendamentos SET id_cliente = ?, id_barbeiro = ?, id_servico = ?, data_hora_agendamento = ?, status = ? WHERE id = ?',
      [appointment.userId, appointment.barberId, appointment.serviceId,
       '${appointment.appointmentDate} ${appointment.appointmentTime}', appointment.status, appointment.id]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Atualizar status do agendamento
  Future<int> updateStatus(int appointmentId, String status) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'UPDATE agendamentos SET status = ? WHERE id = ?',
      [status, appointmentId]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Cancelar agendamento
  Future<int> cancel(int appointmentId) async {
    return await updateStatus(appointmentId, 'cancelado');
  }

  // Deletar agendamento
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('DELETE FROM agendamentos WHERE id = ?', [id]);
    return result.isNotEmpty ? 1 : 0;
  }

  // Listar todos os agendamentos
  Future<List<AppointmentModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM agendamentos ORDER BY data_hora_agendamento DESC');
    
    return result.map((row) {
      final dateTime = DateTime.parse(row['data_hora_agendamento'].toString());
      return AppointmentModel(
        id: row['id'],
        userId: row['id_cliente'],
        barbershopId: 1,
        barberId: row['id_barbeiro'],
        serviceId: row['id_servico'],
        appointmentDate: dateTime.toIso8601String().split('T')[0],
        appointmentTime: '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        status: row['status'],
        totalPrice: 0.0,
        paymentMethod: 'credits',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }).toList();
  }

  // Buscar agendamentos confirmados (ativos)
  Future<List<AppointmentModel>> getActiveAppointments(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT * FROM agendamentos WHERE id_cliente = ? AND status = ? ORDER BY data_hora_agendamento ASC',
      [userId, 'confirmado']
    );
    
    return result.map((row) {
      final dateTime = DateTime.parse(row['data_hora_agendamento'].toString());
      return AppointmentModel(
        id: row['id'],
        userId: row['id_cliente'],
        barbershopId: 1,
        barberId: row['id_barbeiro'],
        serviceId: row['id_servico'],
        appointmentDate: dateTime.toIso8601String().split('T')[0],
        appointmentTime: '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        status: row['status'],
        totalPrice: 0.0,
        paymentMethod: 'credits',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }).toList();
  }
}
