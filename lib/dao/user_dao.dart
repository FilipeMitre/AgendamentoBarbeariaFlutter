import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar usuário
  Future<int> create(UserModel user) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'INSERT INTO usuarios (nome, email, cpf, senha, papel) VALUES (?, ?, ?, ?, ?)',
        [user.name, user.email, user.cpf, user.password, 'cliente']
      );
      print('Usuário criado: ${user.email}');
      return result.isNotEmpty ? 1 : 0;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      return 0;
    }
  }

  // Buscar usuário por ID
  Future<UserModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM usuarios WHERE id = ?', [id]);
    
    if (result.isNotEmpty) {
      final row = result.first;
      return UserModel(
        id: row['id'],
        name: row['nome'],
        email: row['email'],
        cpf: row['cpf'],
        password: row['senha'],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
    return null;
  }

  // Buscar usuário por email
  Future<UserModel?> getByEmail(String email) async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM usuarios WHERE email = ?', [email]);
    
    if (result.isNotEmpty) {
      final row = result.first;
      return UserModel(
        id: row['id'],
        name: row['nome'],
        email: row['email'],
        cpf: row['cpf'],
        password: row['senha'],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
    return null;
  }

  // Login (verificar email e senha)
  Future<UserModel?> login(String email, String password) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        'SELECT * FROM usuarios WHERE email = ? AND senha = ?',
        [email, password]
      );
      
      print('Tentativa de login: $email');
      print('Resultado da consulta: $result');
      
      if (result.isNotEmpty) {
        final row = result.first;
        print('Login bem-sucedido para: $email');
        return UserModel(
          id: row['id'],
          name: row['nome'],
          email: row['email'],
          cpf: row['cpf'],
          password: row['senha'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
      print('Login falhou: credenciais inválidas');
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  // Atualizar usuário
  Future<int> update(UserModel user) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'UPDATE usuarios SET nome = ?, email = ?, cpf = ?, senha = ? WHERE id = ?',
      [user.name, user.email, user.cpf, user.password, user.id]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Atualizar créditos (usando tabela carteiras)
  Future<int> updateCredits(int userId, double newCredits) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'UPDATE carteiras SET saldo = ? WHERE id_cliente = ?',
      [newCredits, userId]
    );
    return result.isNotEmpty ? 1 : 0;
  }

  // Deletar usuário
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('DELETE FROM usuarios WHERE id = ?', [id]);
    return result.isNotEmpty ? 1 : 0;
  }

  // Listar todos os usuários
  Future<List<UserModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('SELECT * FROM usuarios');
    return result.map((row) => UserModel(
      id: row['id'],
      name: row['nome'],
      email: row['email'],
      cpf: row['cpf'],
      password: row['senha'],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    )).toList();
  }
}
