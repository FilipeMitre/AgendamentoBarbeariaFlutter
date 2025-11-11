import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.login(email, password);

      if (response['success']) {
        _user = UserModel.fromJson(response['user']);
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao fazer login');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register({
    required String nome,
    required String cpf,
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.register(
        nome: nome,
        cpf: cpf,
        email: email,
        password: password,
      );

      if (response['success']) {
        _user = UserModel.fromJson(response['user']);
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao cadastrar');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}
