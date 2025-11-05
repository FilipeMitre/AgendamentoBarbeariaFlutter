import 'package:flutter/foundation.dart';

class Usuario {
  final String? papel;
  Usuario({this.papel});
}

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isAuthenticated = false;
  Usuario? usuario;

  AuthProvider();

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    // stub implementation: mark as authenticated
    isAuthenticated = true;
    usuario = Usuario(papel: 'cliente');
    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    isAuthenticated = false;
    usuario = null;
    notifyListeners();
  }
}