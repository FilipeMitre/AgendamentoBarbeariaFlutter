import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/transacao_model.dart';

class CarteiraProvider with ChangeNotifier {
  double _saldo = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  List<TransacaoModel> _transacoes = [];

  double get saldo => _saldo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransacaoModel> get transacoes => _transacoes;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> carregarSaldo(int usuarioId) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getSaldo(usuarioId);

      if (response['success']) {
        _saldo = (response['saldo'] ?? 0).toDouble();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar saldo');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> recarregar(int usuarioId, double valor) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.recarregarCarteira(usuarioId, valor);

      if (response['success']) {
        _saldo = (response['saldo_atual'] ?? _saldo).toDouble();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao realizar recarga');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> carregarTransacoes(int usuarioId) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getTransacoes(usuarioId);

      if (response['success']) {
        _transacoes = (response['transacoes'] as List)
            .map((t) => TransacaoModel.fromJson(t))
            .toList();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar transações');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
