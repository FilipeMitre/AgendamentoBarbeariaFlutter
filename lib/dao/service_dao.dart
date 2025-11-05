import '../database/database_helper.dart';
import '../models/service_model.dart';

class ServiceDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar serviço
  Future<int> create(ServiceModel service) async {
    try {
      final results = await dbHelper.executeQuery(
        'INSERT INTO servicos (id_barbeiro, nome, duracao_minutos, preco_creditos) VALUES (?, ?, ?, ?)',
        [service.barbershopId, service.name, service.durationMinutes, service.price]
      );
      return results.insertId ?? 0;
    } catch (e) {
      print('Erro ao criar serviço: $e');
      return 0;
    }
  }

  // Buscar serviço por ID
  Future<ServiceModel?> getById(int id) async {
    try {
      final result = await dbHelper.query('SELECT * FROM servicos WHERE id = ?', [id]);
      
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
    } catch (e) {
      print('Erro ao buscar serviço: $e');
      return null;
    }
  }

  // Listar serviços de um barbeiro
  Future<List<ServiceModel>> getByBarbershopId(int barberId) async {
    try {
      final result = await dbHelper.query(
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
    } catch (e) {
      print('Erro ao buscar serviços do barbeiro: $e');
      return [];
    }
  }

  // Atualizar serviço
  Future<int> update(ServiceModel service) async {
    try {
      final results = await dbHelper.executeQuery(
        'UPDATE servicos SET nome = ?, duracao_minutos = ?, preco_creditos = ? WHERE id = ?',
        [service.name, service.durationMinutes, service.price, service.id]
      );
      return results.affectedRows ?? 0;
    } catch (e) {
      print('Erro ao atualizar serviço: $e');
      return 0;
    }
  }

  // Deletar serviço
  Future<int> delete(int id) async {
    try {
      final results = await dbHelper.executeQuery('DELETE FROM servicos WHERE id = ?', [id]);
      return results.affectedRows ?? 0;
    } catch (e) {
      print('Erro ao deletar serviço: $e');
      return 0;
    }
  }

  // Listar todos os serviços
  Future<List<ServiceModel>> getAll() async {
    try {
      final result = await dbHelper.query('SELECT * FROM servicos ORDER BY nome ASC');
      
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
    } catch (e) {
      print('Erro ao listar serviços: $e');
      return [];
    }
  }
}