const db = require('../config/database');
const { calcularComissao, calcularValorBarbeiro } = require('../utils/helpers');

// Obter todos os agendamentos do barbeiro
exports.getTodosAgendamentos = async (req, res) => {
  try {
    const { barbeiroId } = req.params;

    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    const [agendamentos] = await db.query(
      `SELECT a.*, 
              c.nome as cliente_nome,
              c.telefone as cliente_telefone,
              s.nome as servico_nome,
              s.duracao_minutos
       FROM agendamentos a
       INNER JOIN usuarios c ON c.id = a.cliente_id
       INNER JOIN servicos s ON s.id = a.servico_id
       WHERE a.barbeiro_id = ?
       ORDER BY a.data_agendamento DESC, a.horario DESC
       LIMIT 50`,
      [barbeiroId]
    );

    res.json({
      success: true,
      agendamentos
    });

  } catch (error) {
    console.error('Erro ao obter todos os agendamentos:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter agendamentos',
      error: error.message
    });
  }
};

// Obter agendamentos do barbeiro por data
exports.getAgendamentosDia = async (req, res) => {
  try {
    const { barbeiroId } = req.params;
    const { data } = req.query;

    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    if (!data) {
      return res.status(400).json({
        success: false,
        message: 'Data é obrigatória'
      });
    }

    const [agendamentos] = await db.query(
      `SELECT a.*, 
              c.nome as cliente_nome,
              c.telefone as cliente_telefone,
              s.nome as servico_nome,
              s.duracao_minutos
       FROM agendamentos a
       INNER JOIN usuarios c ON c.id = a.cliente_id
       INNER JOIN servicos s ON s.id = a.servico_id
       WHERE a.barbeiro_id = ? 
       AND a.data_agendamento = ?
       AND (a.status IS NULL OR a.status IN ('confirmado', 'agendado'))
       ORDER BY a.horario`,
      [barbeiroId, data]
    );

    res.json({
      success: true,
      agendamentos
    });

  } catch (error) {
    console.error('Erro ao obter agendamentos do dia:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter agendamentos',
      error: error.message
    });
  }
};

// Concluir agendamento
exports.concluirAgendamento = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const { agendamentoId } = req.params;

    await connection.beginTransaction();

    // Buscar agendamento
    const [agendamentos] = await connection.query(
      `SELECT * FROM agendamentos WHERE id = ? FOR UPDATE`,
      [agendamentoId]
    );

    if (agendamentos.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Agendamento não encontrado'
      });
    }

    const agendamento = agendamentos[0];

    // Verificar permissão
    if (req.userId != agendamento.barbeiro_id && req.userTipo !== 'admin') {
      await connection.rollback();
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Verificar status
    if (agendamento.status === 'concluido') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Agendamento já foi concluído'
      });
    }

    if (agendamento.status === 'cancelado') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Não é possível concluir um agendamento cancelado'
      });
    }

    // Atualizar status
    await connection.query(
      `UPDATE agendamentos 
       SET status = 'concluido', data_conclusao = NOW()
       WHERE id = ?`,
      [agendamentoId]
    );

    // Calcular comissão e valor do barbeiro
    const valorServico = parseFloat(agendamento.valor_servico);
    const comissao = calcularComissao(valorServico);
    const valorBarbeiro = calcularValorBarbeiro(valorServico, comissao);

    // Buscar carteira do barbeiro
    const [carteirasBarbeiro] = await connection.query(
      'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
      [agendamento.barbeiro_id]
    );

    if (carteirasBarbeiro.length > 0) {
      const carteiraBarbeiro = carteirasBarbeiro[0];
      const saldoAnterior = parseFloat(carteiraBarbeiro.saldo);
      const saldoPosterior = saldoAnterior + valorBarbeiro;

      // Creditar barbeiro
      await connection.query(
        'UPDATE carteiras SET saldo = ? WHERE id = ?',
        [saldoPosterior, carteiraBarbeiro.id]
      );

      // Registrar transação
      await connection.query(
        `INSERT INTO transacoes 
         (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
         VALUES (?, 'recebimento', ?, ?, ?, ?)`,
        [
          carteiraBarbeiro.id,
          valorBarbeiro,
          saldoAnterior,
          saldoPosterior,
          `Pagamento do agendamento #${agendamentoId}`
        ]
      );

      // Registrar comissão
      await connection.query(
        `INSERT INTO transacoes 
         (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
         VALUES (?, 'comissao', ?, ?, ?, ?)`,
        [
          carteiraBarbeiro.id,
          comissao,
          saldoPosterior,
          saldoPosterior,
          `Comissão do agendamento #${agendamentoId}`
        ]
      );
    }

    await connection.commit();

    res.json({
      success: true,
      message: 'Agendamento concluído com sucesso',
      valor_barbeiro: valorBarbeiro,
      comissao: comissao
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao concluir agendamento:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao concluir agendamento',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Cancelar agendamento
exports.cancelarAgendamento = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const { agendamentoId } = req.params;
    const { motivo } = req.body;

    await connection.beginTransaction();

    // Buscar agendamento
    const [agendamentos] = await connection.query(
      `SELECT * FROM agendamentos WHERE id = ? FOR UPDATE`,
      [agendamentoId]
    );

    if (agendamentos.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Agendamento não encontrado'
      });
    }

    const agendamento = agendamentos[0];

    // Verificar permissão
    if (req.userId != agendamento.barbeiro_id && req.userTipo !== 'admin') {
      await connection.rollback();
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Verificar se já foi cancelado
    if (agendamento.status === 'cancelado') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Agendamento já foi cancelado'
      });
    }

    // Verificar se já foi concluído
    if (agendamento.status === 'concluido') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Não é possível cancelar um agendamento já concluído'
      });
    }

    // Atualizar status
    await connection.query(
      `UPDATE agendamentos 
       SET status = 'cancelado', motivo_cancelamento = ?, data_cancelamento = NOW()
       WHERE id = ?`,
      [motivo || 'Cancelado pelo barbeiro', agendamentoId]
    );

    // Estornar valor para o cliente
    const valorServico = parseFloat(agendamento.valor_servico);
    
    const [carteirasCliente] = await connection.query(
      'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
      [agendamento.cliente_id]
    );

    if (carteirasCliente.length > 0) {
      const carteiraCliente = carteirasCliente[0];
      const saldoAnterior = parseFloat(carteiraCliente.saldo);
      const saldoPosterior = saldoAnterior + valorServico;

      // Estornar valor
      await connection.query(
        'UPDATE carteiras SET saldo = ? WHERE id = ?',
        [saldoPosterior, carteiraCliente.id]
      );

      // Registrar transação de estorno
      await connection.query(
        `INSERT INTO transacoes 
         (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
         VALUES (?, 'estorno', ?, ?, ?, ?)`,
        [
          carteiraCliente.id,
          valorServico,
          saldoAnterior,
          saldoPosterior,
          `Estorno do agendamento #${agendamentoId} cancelado`
        ]
      );
    }

    await connection.commit();

    res.json({
      success: true,
      message: 'Agendamento cancelado com sucesso',
      valor_estornado: valorServico
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao cancelar agendamento:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao cancelar agendamento',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Inicializar dados do barbeiro (carteira e agendamento de teste)
exports.inicializarDados = async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    const { barbeiroId } = req.params;
    
    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    await connection.beginTransaction();

    // Criar carteira se não existir
    await connection.query(
      'INSERT IGNORE INTO carteiras (usuario_id, saldo) VALUES (?, 0.00)',
      [barbeiroId]
    );

    // Criar agendamento para hoje se não existir
    const [existeHoje] = await connection.query(
      'SELECT id FROM agendamentos WHERE barbeiro_id = ? AND data_agendamento = CURDATE()',
      [barbeiroId]
    );

    if (existeHoje.length === 0) {
      await connection.query(
        `INSERT INTO agendamentos (
          cliente_id, barbeiro_id, servico_id, data_agendamento, horario,
          valor_servico, valor_comissao, valor_barbeiro, status
        ) VALUES (9004, ?, 1, CURDATE(), '14:00:00', 35.00, 1.75, 33.25, 'confirmado')`,
        [barbeiroId]
      );
    }

    // Marcar um agendamento como concluído para gerar saldo
    const [agendamentoPendente] = await connection.query(
      'SELECT id FROM agendamentos WHERE barbeiro_id = ? AND status = "confirmado" LIMIT 1',
      [barbeiroId]
    );

    if (agendamentoPendente.length > 0) {
      const agendamentoId = agendamentoPendente[0].id;
      
      // Marcar como concluído
      await connection.query(
        'UPDATE agendamentos SET status = "concluido", data_conclusao = NOW() WHERE id = ?',
        [agendamentoId]
      );

      // Creditar barbeiro
      const [carteira] = await connection.query(
        'SELECT id, saldo FROM carteiras WHERE usuario_id = ?',
        [barbeiroId]
      );

      if (carteira.length > 0) {
        const saldoAnterior = parseFloat(carteira[0].saldo);
        const valorBarbeiro = 33.25;
        const saldoPosterior = saldoAnterior + valorBarbeiro;

        await connection.query(
          'UPDATE carteiras SET saldo = ? WHERE id = ?',
          [saldoPosterior, carteira[0].id]
        );

        await connection.query(
          `INSERT INTO transacoes 
           (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
           VALUES (?, 'recebimento', ?, ?, ?, ?)`,
          [
            carteira[0].id,
            valorBarbeiro,
            saldoAnterior,
            saldoPosterior,
            `Pagamento do agendamento #${agendamentoId}`
          ]
        );
      }
    }

    await connection.commit();

    res.json({
      success: true,
      message: 'Dados inicializados com sucesso'
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao inicializar dados:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao inicializar dados',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Obter estatísticas do barbeiro
exports.getEstatisticas = async (req, res) => {
  try {
    const { barbeiroId } = req.params;
    const { data_inicio, data_fim } = req.query;

    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    let whereClause = 'WHERE barbeiro_id = ?';
    let params = [barbeiroId];

    if (data_inicio && data_fim) {
      whereClause += ' AND data_agendamento BETWEEN ? AND ?';
      params.push(data_inicio, data_fim);
    }

    const [stats] = await db.query(
      `SELECT 
         COUNT(*) as total_agendamentos,
         SUM(CASE WHEN status = 'concluido' THEN 1 ELSE 0 END) as agendamentos_concluidos,
         SUM(CASE WHEN status = 'cancelado' THEN 1 ELSE 0 END) as agendamentos_cancelados,
         SUM(CASE WHEN status = 'concluido' THEN valor_servico ELSE 0 END) as receita_total,
         AVG(CASE WHEN status = 'concluido' THEN valor_servico ELSE NULL END) as ticket_medio
       FROM agendamentos
       ${whereClause}`,
      params
    );

    // Buscar saldo atual
    const [carteira] = await db.query(
      'SELECT saldo FROM carteiras WHERE usuario_id = ?',
      [barbeiroId]
    );

    res.json({
      success: true,
      estatisticas: {
        ...stats[0],
        saldo_atual: carteira.length > 0 ? parseFloat(carteira[0].saldo) : 0
      }
    });

  } catch (error) {
    console.error('Erro ao obter estatísticas:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter estatísticas',
      error: error.message
    });
  }
};

// Obter horários de trabalho do barbeiro (resumo por dia)
exports.getHorariosTrabalho = async (req, res) => {
  try {
    const { barbeiroId } = req.params;

    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Buscar horários disponíveis agrupados por dia
    const [horarios] = await db.query(
      `SELECT 
         dia_semana,
         MIN(horario) as hora_inicio,
         MAX(horario) as hora_fim,
         CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END as ativo
       FROM disponibilidade_barbeiro
       WHERE barbeiro_id = ?
       GROUP BY dia_semana
       ORDER BY FIELD(dia_semana, 'domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado')`,
      [barbeiroId]
    );

    // Formatar resposta para incluir os 7 dias da semana
    const dias = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    const horariosFormatados = dias.map(dia => {
      const encontrado = horarios.find(h => h.dia_semana === dia);
      return {
        dia_semana: dia,
        hora_inicio: encontrado?.hora_inicio || '09:00',
        hora_fim: encontrado?.hora_fim || '18:00',
        ativo: encontrado ? true : false
      };
    });

    res.json({
      success: true,
      horarios: horariosFormatados
    });

  } catch (error) {
    console.error('Erro ao obter horários de trabalho:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter horários',
      error: error.message
    });
  }
};

// Atualizar horários de trabalho do barbeiro (gera slots automaticamente)
exports.atualizarHorariosTrabalho = async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    const { barbeiroId } = req.params;
    const { horarios } = req.body; // Array de { dia_semana, hora_inicio, hora_fim, ativo }

    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Validar dados
    if (!Array.isArray(horarios) || horarios.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Horários deve ser um array não vazio'
      });
    }

    const diasValidos = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    const intervaloMinutos = 30; // Intervalo padrão entre slots

    await connection.beginTransaction();

    // Deletar disponibilidades antigas do barbeiro
    await connection.query(
      'DELETE FROM disponibilidade_barbeiro WHERE barbeiro_id = ?',
      [barbeiroId]
    );

    // Processar cada dia
    for (const horario of horarios) {
      const { dia_semana, hora_inicio, hora_fim, ativo = true } = horario;

      // Validações
      if (!dia_semana || !hora_inicio || !hora_fim) {
        await connection.rollback();
        return res.status(400).json({
          success: false,
          message: 'Dados incompletos: dia_semana, hora_inicio e hora_fim são obrigatórios'
        });
      }

      if (!diasValidos.includes(dia_semana)) {
        await connection.rollback();
        return res.status(400).json({
          success: false,
          message: `dia_semana inválido: ${dia_semana}`
        });
      }

      // Se dia está inativo, pular
      if (!ativo) {
        continue;
      }

      // Gerar slots a cada 30 minutos
      let horaAtual = new Date(`2024-01-01 ${hora_inicio}`);
      const horaFimDate = new Date(`2024-01-01 ${hora_fim}`);

      while (horaAtual < horaFimDate) {
        const hora = horaAtual.toLocaleTimeString('pt-BR', { 
          hour: '2-digit', 
          minute: '2-digit',
          hour12: false 
        });

        // Inserir slot de disponibilidade
        await connection.query(
          `INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo)
           VALUES (?, ?, ?, 1)
           ON DUPLICATE KEY UPDATE ativo = 1`,
          [barbeiroId, dia_semana, hora]
        );

        horaAtual.setMinutes(horaAtual.getMinutes() + intervaloMinutos);
      }
    }

    await connection.commit();

    // Retornar novo resumo de horários
    const [horariosAtualizados] = await connection.query(
      `SELECT 
         dia_semana,
         MIN(horario) as hora_inicio,
         MAX(horario) as hora_fim,
         CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END as ativo
       FROM disponibilidade_barbeiro
       WHERE barbeiro_id = ?
       GROUP BY dia_semana
       ORDER BY FIELD(dia_semana, 'domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado')`,
      [barbeiroId]
    );

    res.json({
      success: true,
      message: 'Horários de trabalho atualizados com sucesso',
      horarios: horariosAtualizados
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao atualizar horários de trabalho:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar horários',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Atualizar um único dia de trabalho
exports.atualizarHorarioDia = async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    const { barbeiroId } = req.params;
    const { dia_semana, hora_inicio, hora_fim, ativo = true } = req.body;

    // Verificar permissão
    if (req.userId != barbeiroId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Validar dados
    if (!dia_semana || !hora_inicio || !hora_fim) {
      return res.status(400).json({
        success: false,
        message: 'dia_semana, hora_inicio e hora_fim são obrigatórios'
      });
    }

    const diasValidos = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    if (!diasValidos.includes(dia_semana)) {
      return res.status(400).json({
        success: false,
        message: `dia_semana inválido: ${dia_semana}`
      });
    }

    await connection.beginTransaction();

    // Deletar slots antigos deste dia
    await connection.query(
      'DELETE FROM disponibilidade_barbeiro WHERE barbeiro_id = ? AND dia_semana = ?',
      [barbeiroId, dia_semana]
    );

    // Se está ativo, gerar novos slots
    if (ativo) {
      const intervaloMinutos = 30;
      let horaAtual = new Date(`2024-01-01 ${hora_inicio}`);
      const horaFimDate = new Date(`2024-01-01 ${hora_fim}`);

      while (horaAtual < horaFimDate) {
        const hora = horaAtual.toLocaleTimeString('pt-BR', { 
          hour: '2-digit', 
          minute: '2-digit',
          hour12: false 
        });

        await connection.query(
          `INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo)
           VALUES (?, ?, ?, 1)`,
          [barbeiroId, dia_semana, hora]
        );

        horaAtual.setMinutes(horaAtual.getMinutes() + intervaloMinutos);
      }
    }

    await connection.commit();

    res.json({
      success: true,
      message: 'Horário atualizado com sucesso',
      horario: {
        barbeiro_id: barbeiroId,
        dia_semana,
        hora_inicio,
        hora_fim,
        ativo
      }
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao atualizar horário do dia:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar horário',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

