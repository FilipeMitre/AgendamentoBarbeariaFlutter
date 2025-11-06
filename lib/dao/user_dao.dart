import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../services/token_manager.dart';

class UserDao {
  final dbHelper = DatabaseHelper.instance;

  // Criar usuário via API
  Future<int> create(UserModel user) async {
    try {
      final result = await dbHelper.executeQuery(
        'INSERT INTO usuarios (nome, email, cpf, senha, papel) VALUES (?, ?, ?, ?, ?)',
        [user.name, user.email, user.cpf, user.password, 'cliente']
      );
      
      print('Usuário criado via API: ${user.email}');
      return result['insertId'] ?? 0;
    } catch (e) {
      print('Erro ao criar usuário via API: $e');
      if (e.toString().contains('Duplicate entry')) {
        throw Exception('EMAIL_EXISTS');
      }
      rethrow;
    }
  }

  // Buscar usuário por email via API
  Future<UserModel?> getByEmail(String email) async {
    try {
      final result = await dbHelper.query('SELECT * FROM usuarios WHERE email = ?', [email]);
      
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
    } catch (e) {
      print('Erro ao buscar usuário via API: $e');
      return null;
    }
  }

  // Login via API
  Future<UserModel?> login(String email, String password) async {
    try {
      final result = await dbHelper.query(
        'SELECT * FROM usuarios WHERE email = ? AND senha = ?',
        [email, password]
      );
      
      print('Tentativa de login via API: $email');
      
      if (result.isNotEmpty) {
        final row = result.first;
        print('Login bem-sucedido via API: $email');
        final user = UserModel(
          id: row['id'],
          name: row['nome'],
          email: row['email'],
          cpf: row['cpf'],
          password: row['senha'],
          role: row['papel'] ?? 'cliente',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        // Salvar dados do usuário incluindo o papel
        await TokenManager.saveUserData({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role': user.role,
        });
        
        return user;
      }
      
      print('Login falhou via API: credenciais inválidas');
      return null;
    } catch (e) {
      print('Erro no login via API: $e');
      return null;
    }
  }

  // Buscar usuário por ID via API
  Future<UserModel?> getById(int id) async {
    try {
      final result = await dbHelper.query('SELECT * FROM usuarios WHERE id = ?', [id]);
      
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
    } catch (e) {
      print('Erro ao buscar usuário por ID via API: $e');
      return null;
    }
  }
}