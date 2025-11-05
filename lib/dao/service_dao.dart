import '../database/database_helper.dart';
import '../models/service_model.dart';

class ServiceDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar serviço
  Future<int> create(ServiceModel service) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'INSERT INTO servicos (id_barbeiro, nome, duracao_minutos, preco_creditos) VALUES (?, ?, ?, ?)',
      [service.barbershopId, service.name, service.durationMinutes, service.price]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Buscar serviço por ID
  Future<ServiceModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM servicos WHERE id = ?', [id]);
    
    if (result.isNotEmpty) {
      final row = result.first;
      return ServiceModel(
        id: row['id'],
        barbershopId: row['id_barbeiro'],
        name: row['nome'],
        description: '',
        price: double.parse(row['preco_creditos'].toString()),
        durationMinutes: row['duracao_minutos'],
        isAvailable: true,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
    return null;
  }

  // Listar serviços de um barbeiro
  Future<List<ServiceModel>> getByBarbershopId(int barberId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'SELECT * FROM servicos WHERE id_barbeiro = ? ORDER BY preco_creditos ASC',
      [barberId]
    );
    
    return result.map((row) => ServiceModel(
      id: row['id'],
      barbershopId: row['id_barbeiro'],
      name: row['nome'],
      description: '',
      price: double.parse(row['preco_creditos'].toString()),
      durationMinutes: row['duracao_minutos'],
      isAvailable: true,
      createdAt: DateTime.now().toIso8601String(),
    )).toList();
  }

  // Atualizar serviço
  Future<int> update(ServiceModel service) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'UPDATE servicos SET nome = ?, duracao_minutos = ?, preco_creditos = ? WHERE id = ?',
      [service.name, service.durationMinutes, service.price, service.id]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Deletar serviço
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('DELETE FROM servicos WHERE id = ?', [id]);
    return result.isNotEmpty ? 1 : 0;
  }

  // Listar todos os serviços
  Future<List<ServiceModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM servicos ORDER BY nome ASC');
    
    return result.map((row) => ServiceModel(
      id: row['id'],
      barbershopId: row['id_barbeiro'],
      name: row['nome'],
      description: '',
      price: double.parse(row['preco_creditos'].toString()),
      durationMinutes: row['duracao_minutos'],
      isAvailable: true,
      createdAt: DateTime.now().toIso8601String(),
    )).toList();
  }
}
