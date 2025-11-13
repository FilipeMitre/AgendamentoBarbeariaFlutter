import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/agendamento_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DetalhesAgendamentoBarbeiroDialog extends StatefulWidget {
  final AgendamentoModel agendamento;
  final VoidCallback? onUpdate;

  const DetalhesAgendamentoBarbeiroDialog({
    super.key,
    required this.agendamento,
    this.onUpdate,
  });

  @override
  State<DetalhesAgendamentoBarbeiroDialog> createState() => _DetalhesAgendamentoBarbeiroDialogState();
}

class _DetalhesAgendamentoBarbeiroDialogState extends State<DetalhesAgendamentoBarbeiroDialog> {

  @override
  Widget build(BuildContext context) {
    final isConcluido = widget.agendamento.status == 'concluido';
    final dataFormatada = DateFormat('EEEE', 'pt_BR')
        .format(widget.agendamento.dataAgendamento)
        .toUpperCase()
        .substring(0, 3);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Data e Horário
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB84D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.agendamento.dataAgendamento.day.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        dataFormatada,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.agendamento.horario,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status do Serviço
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isConcluido
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isConcluido ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isConcluido
                          ? const Color(0xFF4CAF50)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConcluido ? 'Completo' : 'Pendente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isConcluido
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.agendamento.servicoNome,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Nome do Cliente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Cliente:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.agendamento.clienteNome ?? 'Cliente não informado',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botões de ação
            if (!isConcluido) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _concluirAgendamento(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text(
                    'Marcar como Concluído',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrarDialogCancelar(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text(
                    'Cancelar Agendamento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _concluirAgendamento() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.token == null) return;

    try {
      final response = await ApiService.concluirAgendamento(
        widget.agendamento.id!,
        authProvider.token!,
      );

      if (response['success'] == true && mounted) {
        Navigator.pop(context);
        widget.onUpdate?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agendamento concluído! Você recebeu R\$ ${response['valor_barbeiro']?.toStringAsFixed(2) ?? '0,00'}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro ao concluir agendamento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelarAgendamento() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.token == null) return;

    try {
      final response = await ApiService.cancelarAgendamentoBarbeiro(
        widget.agendamento.id!,
        'Cancelado pelo barbeiro',
        authProvider.token!,
      );

      if (response['success'] == true && mounted) {
        Navigator.pop(context);
        widget.onUpdate?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento cancelado'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro ao cancelar agendamento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogCancelar(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        title: const Text(
          'Cancelar Agendamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento? Esta ação não pode ser desfeita.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Voltar',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelarAgendamento();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
