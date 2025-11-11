import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';
import '../services/api_service.dart';

class AgendamentoProvider with ChangeNotifier {
  List<AgendamentoModel> _agendamentosAtivos = [];
  List<AgendamentoModel> _historicoAgendamentos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AgendamentoModel> get agendamentosAtivos => _agendamentosAtivos;
  List<AgendamentoModel> get historicoAgendamentos => _historicoAgendamentos;
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

  Future<bool> carregarAgendamentosAtivos(int usuarioId) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getAgendamentosAtivos(usuarioId);

      if (response['success']) {
        _agendamentosAtivos = (response['agendamentos'] as List)
            .map((a) => AgendamentoModel.fromJson(a))
            .toList();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar agendamentos');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> carregarHistoricoAgendamentos(int usuarioId) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getHistoricoAgendamentos(usuarioId);

      if (response['success']) {
        _historicoAgendamentos = (response['agendamentos'] as List)
            .map((a) => AgendamentoModel.fromJson(a))
            .toList();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar histórico');
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
