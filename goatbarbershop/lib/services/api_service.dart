import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Alterar para seu servidor

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String nome,
    required String cpf,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'cpf': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
          'email': email,
          'senha': password,
          'telefone': '', // Será adicionado depois
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }
    // Métodos de Carteira
  static Future<Map<String, dynamic>> getSaldo(int usuarioId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carteira/$usuarioId/saldo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> recarregarCarteira(
    int usuarioId,
    double valor,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carteira/$usuarioId/recarregar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'valor': valor}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> getTransacoes(int usuarioId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carteira/$usuarioId/transacoes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }
    // Métodos de Agendamento
  static Future<Map<String, dynamic>> criarAgendamento({
    required int clienteId,
    required int barbeiroId,
    required int servicoId,
    required String dataAgendamento,
    required String horario,
    required String token,
    Map<String, double>? produtos,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agendamentos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'barbeiro_id': barbeiroId,
          'servico_id': servicoId,
          'data_agendamento': dataAgendamento,
          'horario': horario,
          'produtos': produtos,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> getAgendamentosAtivos(int usuarioId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agendamentos/$usuarioId/ativos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Verificar se horário ainda está disponível antes de confirmar
  static Future<Map<String, dynamic>> verificarDisponibilidade({
    required int barbeiroId,
    required String dataAgendamento,
    required String horario,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agendamentos/verificar-disponibilidade?barbeiro_id=$barbeiroId&data=$dataAgendamento&horario=$horario'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> getHistoricoAgendamentos(int usuarioId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agendamentos/$usuarioId/historico'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Métodos de Avaliação
  static Future<Map<String, dynamic>> enviarAvaliacao({
    required int agendamentoId,
    required int notaBarbearia,
    required int notaBarbeiro,
    String? comentarioBarbearia,
    String? comentarioBarbeiro,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/avaliacoes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'agendamento_id': agendamentoId,
          'nota_barbearia': notaBarbearia,
          'nota_barbeiro': notaBarbeiro,
          'comentario_barbearia': comentarioBarbearia,
          'comentario_barbeiro': comentarioBarbeiro,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }
    // Métodos do Barbeiro
  static Future<Map<String, dynamic>> getAgendamentosBarbeiro(
    int barbeiroId,
    DateTime data,
  ) async {
    try {
      final dataFormatada = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('$baseUrl/barbeiro/$barbeiroId/agendamentos?data=$dataFormatada'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Obter horários disponíveis em tempo real
  static Future<Map<String, dynamic>> getHorariosDisponiveis(
    int barbeiroId,
    DateTime data,
  ) async {
    try {
      final dataFormatada = DateFormat('yyyy-MM-dd').format(data);
      final response = await http.get(
        Uri.parse('$baseUrl/agendamentos/horarios-disponiveis?barbeiro_id=$barbeiroId&data=$dataFormatada'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Obter dias disponíveis (próximos 30 dias)
  static Future<Map<String, dynamic>> getDiasDisponiveis(int barbeiroId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agendamentos/dias-disponiveis?barbeiro_id=$barbeiroId'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> concluirAgendamento(int agendamentoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/agendamentos/$agendamentoId/concluir'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> cancelarAgendamentoBarbeiro(
    int agendamentoId,
    String motivo,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/agendamentos/$agendamentoId/cancelar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'motivo': motivo}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }
  // Métodos Admin
  static Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      // TODO: Obter token de forma segura
      const token = ''; 
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBarberDashboard() async {
    try {
      // TODO: Obter token de forma segura
      const token = '';
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/barber'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> atualizarUsuario(
    int usuarioId,
    String tipo,
    bool ativo,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/usuarios/$usuarioId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tipo_usuario': tipo,
          'ativo': ativo,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> getServicos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/servicos'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> adicionarServico(
    String nome,
    String descricao,
    double preco,
    int duracao,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/servicos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'descricao': descricao,
          'preco_base': preco,
          'duracao_minutos': duracao,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> atualizarServico(
    int servicoId,
    String nome,
    String descricao,
    double preco,
    int duracao,
    bool ativo,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/servicos/$servicoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'descricao': descricao,
          'preco_base': preco,
          'duracao_minutos': duracao,
          'ativo': ativo,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> getProdutosAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/produtos'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> atualizarProduto(
    int produtoId,
    String nome,
    double preco,
    int estoque,
    bool ativo,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/produtos/$produtoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'preco': preco,
          'estoque': estoque,
          'ativo': ativo,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }
}
