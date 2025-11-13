import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/servico_model.dart';
import '../models/produto_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class AdminProvider with ChangeNotifier {
  List<UserModel> _usuarios = [];
  List<ServicoModel> _servicos = [];
  List<ProdutoModel> _produtos = [];
  Map<String, dynamic>? _dashboardData;

  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get usuarios => _usuarios;
  List<ServicoModel> get servicos => _servicos;
  List<ProdutoModel> get produtos => _produtos;
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

  Future<void> fetchAdminDashboard() async {
    try {
      setLoading(true);
      setError(null);
      final response = await ApiService.getAdminDashboard();
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

  Future<bool> carregarUsuarios(String token) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getUsuariosAdmin(token);

      if (response['success']) {
        _usuarios = (response['usuarios'] as List)
            .map((u) => UserModel.fromJson(u))
            .toList();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar usuários');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> atualizarUsuario(int usuarioId, String tipo, bool ativo) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.atualizarUsuario(usuarioId, tipo, ativo);

      if (response['success']) {
        // Atualizar localmente
        final index = _usuarios.indexWhere((u) => u.id == usuarioId);
        if (index != -1) {
          _usuarios[index] = UserModel.fromJson(response['usuario']);
        }
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao atualizar usuário');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> carregarServicos() async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getServicos();

      if (response['success']) {
        _servicos = (response['servicos'] as List)
            .map((s) => ServicoModel.fromJson(s))
            .toList();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar serviços');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> adicionarServico(String nome, String descricao, double preco, int duracao) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.adicionarServico(nome, descricao, preco, duracao);

      if (response['success']) {
        _servicos.add(ServicoModel.fromJson(response['servico']));
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao adicionar serviço');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> atualizarServico(int servicoId, String nome, String descricao, double preco, int duracao, bool ativo) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.atualizarServico(servicoId, nome, descricao, preco, duracao, ativo);

      if (response['success']) {
        final index = _servicos.indexWhere((s) => s.id == servicoId);
        if (index != -1) {
          _servicos[index] = ServicoModel.fromJson(response['servico']);
        }
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao atualizar serviço');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> carregarProdutos() async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.getProdutosAdmin();

      if (response['success']) {
        _produtos = (response['produtos'] as List)
            .map((p) => ProdutoModel.fromJson(p))
            .toList();
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao carregar produtos');
        return false;
      }
    } catch (e) {
      setError('Erro de conexão: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> atualizarProduto(int produtoId, String nome, double preco, int estoque, bool ativo) async {
    try {
      setLoading(true);
      setError(null);

      final response = await ApiService.atualizarProduto(produtoId, nome, preco, estoque, ativo);

      if (response['success']) {
        final index = _produtos.indexWhere((p) => p.id == produtoId);
        if (index != -1) {
          _produtos[index] = ProdutoModel.fromJson(response['produto']);
        }
        notifyListeners();
        return true;
      } else {
        setError(response['message'] ?? 'Erro ao atualizar produto');
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
