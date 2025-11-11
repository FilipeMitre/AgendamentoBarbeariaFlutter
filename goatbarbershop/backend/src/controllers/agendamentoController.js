const db = require('../config/database');
const { formatDateForMySQL, calcularComissao, calcularValorBarbeiro } = require('../utils/helpers');

// Criar agendamento
exports.criarAgendamento = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const {
      barbeiro_id,
      servico_id,
      data_agendamento,
      horario,
      produtos
    } = req.body;

    const cliente_id = req.userId;

    // Validações
    if (!barbeiro_id || !servico_id || !data_agendamento || !horario) {
      return res.status(400).json({
        success: false,
        message: 'Dados incompletos'
      });
    }

    await connection.beginTransaction();

    // Buscar serviço
    const [servicos] = await connection.query(
      'SELECT preco_base FROM servicos WHERE id = ? AND ativo = TRUE',
      [servico_id]
    );

    if (servicos.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Serviço não encontrado'
      });
    }

    const valorServico = parseFloat(servicos[0].preco_base);

    // Calcular valor total (serviço + produtos)
    let valorTotal = valorServico;

    if (produtos && produtos.length > 0) {
      for (const produto of produtos) {
        valorTotal += parseFloat(produto.preco) * parseInt(produto.quantidade);
      }
    }

    // Buscar carteira do cliente
    const [carteiras] = await connection.query(
      'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
      [cliente_id]
    );

    if (carteiras.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Carteira não encontrada'
      });
    }

    const carteira = carteiras[0];
    const saldoAtual = parseFloat(carteira.saldo);

    // Verificar saldo
    if (saldoAtual < valorTotal) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Saldo insuficiente',
        saldo_atual: saldoAtual,
        valor_necessario: valorTotal
      });
    }

    // Verificar disponibilidade do horário
    const [agendamentosExistentes] = await connection.query(
      `SELECT id FROM agendamentos 
       WHERE barbeiro_id = ? 
       AND data_agendamento = ? 
       AND horario = ? 
       AND status NOT IN ('cancelado', 'concluido')`,
      [barbeiro_id, data_agendamento, horario]
    );

    if (agendamentosExistentes.length > 0) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Horário não disponível'
      });
    }

    // Criar agendamento
    const [agendamentoResult] = await connection.query(
      `INSERT INTO agendamentos 
       (cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valor_servico, status)
       VALUES (?, ?, ?, ?, ?, ?, 'confirmado')`,
      [cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valorServico]
    );

    const agendamentoId = agendamentoResult.insertId;

    // Adicionar produtos ao agendamento (se houver)
    if (produtos && produtos.length > 0) {
      for (const produto of produtos) {
        await connection.query(
          `INSERT INTO agendamento_produtos 
           (agendamento_id, produto_id, quantidade, preco_unitario)
           VALUES (?, ?, ?, ?)`,
          [agendamentoId, produto.produto_id, produto.quantidade, produto.preco]
        );

        // Atualizar estoque
        await connection.query(
          'UPDATE produtos SET estoque = estoque - ? WHERE id = ?',
          [produto.quantidade, produto.produto_id]
        );
      }
    }

    // Debitar da carteira do cliente
    const novoSaldo = saldoAtual - valorTotal;
    await connection.query(
      'UPDATE carteiras SET saldo = ? WHERE id = ?',
      [novoSaldo, carteira.id]
    );

    // Registrar transação
    await connection.query(
      `INSERT INTO transacoes 
       (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
       VALUES (?, 'pagamento', ?, ?, ?, ?)`,
      [
        carteira.id,
        valorTotal,
        saldoAtual,
        novoSaldo,
        `Agendamento #${agendamentoId}`
      ]
    );

    await connection.commit();

    // Buscar agendamento completo
    const [agendamento] = await connection.query(
      `SELECT a.*, 
              u.nome as cliente_nome,
              b.nome as barbeiro_nome,
              s.nome as servico_nome
       FROM agendamentos a
       INNER JOIN usuarios u ON u.id = a.cliente_id
       INNER JOIN usuarios b ON b.id = a.barbeiro_id
       INNER JOIN servicos s ON s.id = a.servico_id
       WHERE a.id = ?`,
      [agendamentoId]
    );

    res.status(201).json({
      success: true,
      message: 'Agendamento criado com sucesso',
      agendamento: agendamento[0]
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao criar agendamento:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar agendamento',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Obter agendamentos ativos do cliente
exports.getAgendamentosAtivos = async (req, res) => {
  try {
    const { usuarioId } = req.params;

    // Verificar permissão
    if (req.userId != usuarioId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    const [agendamentos] = await db.query(
      `SELECT a.*, 
              b.nome as barbeiro_nome,
              s.nome as servico_nome,
              s.duracao_minutos
       FROM agendamentos a
       INNER JOIN usuarios b ON b.id = a.barbeiro_id
       INNER JOIN servicos s ON s.id = a.servico_id
       WHERE a.cliente_id = ? 
       AND a.status IN ('confirmado', 'em_andamento')
       AND CONCAT(a.data_agendamento, ' ', a.horario) >= NOW()
       ORDER BY a.data_agendamento, a.horario`,
      [usuarioId]
    );

    res.json({
      success: true,
      agendamentos
    });

  } catch (error) {
    console.error('Erro ao obter agendamentos ativos:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter agendamentos',
      error: error.message
    });
  }
};

// Obter histórico de agendamentos
exports.getHistoricoAgendamentos = async (req, res) => {
  try {
    const { usuarioId } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    // Verificar permissão
    if (req.userId != usuarioId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    const [agendamentos] = await db.query(
      `SELECT a.*, 
              b.nome as barbeiro_nome,
              s.nome as servico_nome,
              s.duracao_minutos
       FROM agendamentos a
       INNER JOIN usuarios b ON b.id = a.barbeiro_id
       INNER JOIN servicos s ON s.id = a.servico_id
       WHERE a.cliente_id = ?
       ORDER BY a.data_agendamento DESC, a.horario DESC
       LIMIT ? OFFSET ?`,
      [usuarioId, parseInt(limit), parseInt(offset)]
    );

    res.json({
      success: true,
      agendamentos
    });

  } catch (error) {
    console.error('Erro ao obter histórico:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter histórico',
      error: error.message
    });
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
      `SELECT a.*, 
              TIMESTAMPDIFF(HOUR, NOW(), CONCAT(a.data_agendamento, ' ', a.horario)) as horas_ate_agendamento
       FROM agendamentos a
       WHERE a.id = ? FOR UPDATE`,
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
    if (req.userId != agendamento.cliente_id && req.userTipo !== 'admin' && req.userTipo !== 'barbeiro') {
      await connection.rollback();
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Verificar se já foi cancelado ou concluído
    if (agendamento.status === 'cancelado') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Agendamento já foi cancelado'
      });
    }

    if (agendamento.status === 'concluido') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Não é possível cancelar um agendamento concluído'
      });
    }

    // Calcular taxa de cancelamento
    const prazoCancelamento = parseInt(process.env.PRAZO_CANCELAMENTO) || 2;
    const taxaCancelamento = parseFloat(process.env.TAXA_CANCELAMENTO) || 10;

    let valorEstorno = parseFloat(agendamento.valor_servico);
    let aplicarTaxa = false;

    if (agendamento.horas_ate_agendamento < prazoCancelamento) {
      aplicarTaxa = true;
      const valorTaxa = (valorEstorno * taxaCancelamento) / 100;
      valorEstorno = valorEstorno - valorTaxa;
    }

    // Atualizar status do agendamento
    await connection.query(
      `UPDATE agendamentos 
       SET status = 'cancelado', 
           data_cancelamento = NOW(),
           motivo_cancelamento = ?
       WHERE id = ?`,
      [motivo || 'Cancelado pelo usuário', agendamentoId]
    );

    // Buscar carteira do cliente
    const [carteiras] = await connection.query(
      'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
      [agendamento.cliente_id]
    );

    if (carteiras.length > 0) {
      const carteira = carteiras[0];
      const saldoAnterior = parseFloat(carteira.saldo);
      const saldoPosterior = saldoAnterior + valorEstorno;

      // Estornar valor
      await connection.query(
        'UPDATE carteiras SET saldo = ? WHERE id = ?',
        [saldoPosterior, carteira.id]
      );

      // Registrar transação de estorno
      await connection.query(
        `INSERT INTO transacoes 
         (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
         VALUES (?, 'estorno', ?, ?, ?, ?)`,
        [
          carteira.id,
          valorEstorno,
          saldoAnterior,
          saldoPosterior,
          `Estorno do agendamento #${agendamentoId}${aplicarTaxa ? ' (com taxa de cancelamento)' : ''}`
        ]
      );

      // Se aplicou taxa, registrar
      if (aplicarTaxa) {
        const valorTaxa = parseFloat(agendamento.valor_servico) - valorEstorno;
        await connection.query(
          `INSERT INTO transacoes 
           (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
           VALUES (?, 'taxa_cancelamento', ?, ?, ?, ?)`,
          [
            carteira.id,
            valorTaxa,
            saldoPosterior,
            saldoPosterior,
            `Taxa de cancelamento tardio - Agendamento #${agendamentoId}`
          ]
        );
      }
    }

    // Restaurar estoque de produtos (se houver)
    const [produtosAgendamento] = await connection.query(
      'SELECT produto_id, quantidade FROM agendamento_produtos WHERE agendamento_id = ?',
      [agendamentoId]
    );

    for (const produto of produtosAgendamento) {
      await connection.query(
        'UPDATE produtos SET estoque = estoque + ? WHERE id = ?',
        [produto.quantidade, produto.produto_id]
      );
    }

    await connection.commit();

    res.json({
      success: true,
      message: 'Agendamento cancelado com sucesso',
      valor_estornado: valorEstorno,
      taxa_aplicada: aplicarTaxa
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
