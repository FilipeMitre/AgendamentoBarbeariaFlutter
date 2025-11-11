import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AvaliacaoProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> enviarAvaliacao({
    required int agendamentoId,
    required int notaBarbearia,
    required int notaBarbeiro,
    String? comentarioBarbearia,
    String? comentarioBarbeiro,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.enviarAvaliacao(
        agendamentoId: agendamentoId,
        notaBarbearia: notaBarbearia,
        notaBarbeiro: notaBarbeiro,
        comentarioBarbearia: comentarioBarbearia,
        comentarioBarbeiro: comentarioBarbeiro,
      );

      if (response['success']) {
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao enviar avaliação');
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
