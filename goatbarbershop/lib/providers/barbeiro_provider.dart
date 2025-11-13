import 'package:flutter/material.dart';
import '../models/agendamento_model.dart';
import '../services/api_service.dart';

class BarbeiroProvider with ChangeNotifier {
  List<AgendamentoModel> _agendamentosDia = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  List<AgendamentoModel> get agendamentosDia => _agendamentosDia;
  Map<String, dynamic>? get dashboardData => _dashboardData;
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

  Future<void> fetchBarberDashboard() async {
    try {
      setLoading(true);
      setError(null);
      final response = await ApiService.getBarberDashboard();
      if (response['success']) {
        _dashboardData = response['data'];
      } else {
        setError(response['message']);
      }
    } catch (e) {
      setError('Falha ao carregar dados do dashboard: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> carregarAgendamentosDia(int barbeiroId, DateTime data, String token) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getAgendamentosBarbeiro(barbeiroId, data, token);

      if (response['success']) {
        _agendamentosDia = (response['agendamentos'] as List)
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

  Future<bool> concluirAgendamento(int agendamentoId, String token) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.concluirAgendamento(agendamentoId, token);

      if (response['success']) {
        // Atualizar status localmente
        final index = _agendamentosDia.indexWhere((a) => a.id == agendamentoId);
        if (index != -1) {
          // Criar novo agendamento com status atualizado
          // (implementar método copyWith no model)
        }
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao concluir agendamento');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> cancelarAgendamento(int agendamentoId, String motivo, String token) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.cancelarAgendamentoBarbeiro(
        agendamentoId,
        motivo,
        token,
      );

      if (response['success']) {
        // Remover agendamento da lista
        _agendamentosDia.removeWhere((a) => a.id == agendamentoId);
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao cancelar agendamento');
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
