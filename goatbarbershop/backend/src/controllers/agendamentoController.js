const db = require('../config/database');
const { formatDateForMySQL, calcularComissao, calcularValorBarbeiro } = require('../utils/helpers');

// Criar agendamento
exports.criarAgendamento = async (req, res) => {
  const connection = await db.getConnection();

  try {
    console.log('DEBUG: Dados recebidos:', req.body);
    console.log('DEBUG: Cliente ID:', req.userId);
    
    const {
      barbeiro_id,
      servico_id,
      data_agendamento,
      horario
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

    // Buscar serviço e configurações de comissão
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

    // Buscar a taxa de comissão do sistema
    const [config] = await connection.query(
        "SELECT valor FROM configuracoes_sistema WHERE chave = 'taxa_comissao_servico' LIMIT 1"
    );
    const taxaComissao = config.length > 0 ? parseFloat(config[0].valor) : 5.0; // Default 5%

    console.log('DEBUG: Taxa comissão:', taxaComissao);
    console.log('DEBUG: Valor serviço:', valorServico);

    // Calcular comissão e valor para o barbeiro
    const valorComissao = calcularComissao(valorServico, taxaComissao);
    const valorBarbeiro = calcularValorBarbeiro(valorServico, valorComissao);
    
    console.log('DEBUG: Valor comissão:', valorComissao);
    console.log('DEBUG: Valor barbeiro:', valorBarbeiro);


    // Buscar ou criar carteira do cliente
    let [carteiras] = await connection.query(
      'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
      [cliente_id]
    );

    if (carteiras.length === 0) {
      // Criar carteira se não existir
      await connection.query(
        'INSERT INTO carteiras (usuario_id, saldo) VALUES (?, 0.00)',
        [cliente_id]
      );
      
      [carteiras] = await connection.query(
        'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
        [cliente_id]
      );
    }

    const carteira = carteiras[0];
    const saldoAtual = parseFloat(carteira.saldo);

    // Verificar saldo
    if (saldoAtual < valorServico) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Saldo insuficiente',
        saldo_atual: saldoAtual,
        valor_necessario: valorServico
      });
    }

    // Verificar se não é agendamento no passado
    const dataHoraAgendamento = new Date(data_agendamento + ' ' + horario);
    const agora = new Date();
    
    if (dataHoraAgendamento <= agora) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Não é possível agendar para horários passados'
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
    // Debug: log variables de sessão do MySQL para verificar charset/collation
    try {
      const [sessionVars] = await connection.query(
        "SELECT @@character_set_client AS character_set_client, @@character_set_connection AS character_set_connection, @@collation_connection AS collation_connection"
      );
      console.log('DEBUG MySQL session vars before INSERT:', sessionVars[0]);
    } catch (dbgErr) {
      console.warn('Não foi possível obter variáveis de sessão MySQL:', dbgErr.message);
    }

    const [agendamentoResult] = await connection.query(
      `INSERT INTO agendamentos 
       (cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valor_servico, valor_comissao, valor_barbeiro, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'confirmado')`,
      [cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valorServico, valorComissao, valorBarbeiro]
    );

    const agendamentoId = agendamentoResult.insertId;

    // Debitar da carteira do cliente
    const novoSaldo = saldoAtual - valorServico;
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
        valorServico,
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

// Obter horários disponíveis para um barbeiro em uma data específica
exports.getHorariosDisponiveis = async (req, res) => {
  try {
    const { barbeiro_id, data } = req.query;

    if (!barbeiro_id || !data) {
      return res.status(400).json({
        success: false,
        message: 'Barbeiro e data são obrigatórios'
      });
    }

    // Verificar se a data não é no passado
    const dataAgendamento = new Date(data);
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    
    if (dataAgendamento < hoje) {
      return res.json({
        success: true,
        horarios: []
      });
    }

    // Horários padrão da barbearia (8h às 18h)
    const horariosBase = [
      '08:00', '09:00', '10:00', '11:00', '12:00',
      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
    ];

    // Buscar agendamentos já marcados
    const [agendamentosOcupados] = await db.query(
      `SELECT horario FROM agendamentos 
       WHERE barbeiro_id = ? 
       AND data_agendamento = ? 
       AND status NOT IN ('cancelado')`,
      [barbeiro_id, data]
    );

    const horariosOcupados = agendamentosOcupados.map(a => a.horario);

    // Se for hoje, filtrar horários que já passaram
    let horariosDisponiveis = horariosBase;
    if (dataAgendamento.toDateString() === hoje.toDateString()) {
      const agora = new Date();
      const horaAtual = agora.getHours();
      const minutoAtual = agora.getMinutes();
      
      horariosDisponiveis = horariosBase.filter(horario => {
        const [hora, minuto] = horario.split(':').map(Number);
        return hora > horaAtual || (hora === horaAtual && minuto > minutoAtual + 30); // 30min de antecedência
      });
    }

    // Remover horários ocupados
    horariosDisponiveis = horariosDisponiveis.filter(h => !horariosOcupados.includes(h));

    res.json({
      success: true,
      horarios: horariosDisponiveis
    });

  } catch (error) {
    console.error('Erro ao obter horários disponíveis:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter horários disponíveis',
      error: error.message
    });
  }
};

// Obter dias disponíveis (próximos 30 dias úteis)
exports.getDiasDisponiveis = async (req, res) => {
  try {
    const { barbeiro_id } = req.query;

    if (!barbeiro_id) {
      return res.status(400).json({
        success: false,
        message: 'ID do barbeiro é obrigatório'
      });
    }

    const diasDisponiveis = [];
    const hoje = new Date();
    
    // Gerar próximos 30 dias (excluindo domingos)
    for (let i = 0; i < 45; i++) {
      const data = new Date(hoje);
      data.setDate(hoje.getDate() + i);
      
      // Pular domingos (0 = domingo)
      if (data.getDay() === 0) continue;
      
      // Verificar se tem pelo menos um horário disponível
      const dataFormatada = data.toISOString().split('T')[0];
      const [agendamentos] = await db.query(
        `SELECT COUNT(*) as total FROM agendamentos 
         WHERE barbeiro_id = ? 
         AND data_agendamento = ? 
         AND status NOT IN ('cancelado')`,
        [barbeiro_id, dataFormatada]
      );

      const totalAgendamentos = agendamentos[0].total;
      const horariosBase = 11; // 8h às 18h = 11 horários
      
      // Se for hoje, considerar apenas horários futuros
      let horariosDisponiveis = horariosBase;
      if (data.toDateString() === hoje.toDateString()) {
        const agora = new Date();
        const horaAtual = agora.getHours();
        horariosDisponiveis = Math.max(0, 18 - Math.max(8, horaAtual + 1));
      }

      if (totalAgendamentos < horariosDisponiveis) {
        diasDisponiveis.push({
          data: dataFormatada,
          dia_semana: data.getDay(),
          horarios_livres: horariosDisponiveis - totalAgendamentos
        });
      }

      if (diasDisponiveis.length >= 30) break;
    }

    res.json({
      success: true,
      dias: diasDisponiveis
    });

  } catch (error) {
    console.error('Erro ao obter dias disponíveis:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter dias disponíveis',
      error: error.message
    });
  }
};

// Verificar disponibilidade de um horário específico
exports.verificarDisponibilidade = async (req, res) => {
  try {
    const { barbeiro_id, data, horario } = req.query;

    if (!barbeiro_id || !data || !horario) {
      return res.status(400).json({
        success: false,
        message: 'Barbeiro, data e horário são obrigatórios'
      });
    }

    // Verificar se não é no passado
    const dataAgendamento = new Date(data + ' ' + horario);
    const agora = new Date();
    
    if (dataAgendamento <= agora) {
      return res.json({
        success: false,
        disponivel: false,
        message: 'Horário no passado'
      });
    }

    // Verificar se já está ocupado
    const [agendamentos] = await db.query(
      `SELECT id FROM agendamentos 
       WHERE barbeiro_id = ? 
       AND data_agendamento = ? 
       AND horario = ? 
       AND status NOT IN ('cancelado')`,
      [barbeiro_id, data, horario]
    );

    const disponivel = agendamentos.length === 0;

    res.json({
      success: true,
      disponivel,
      message: disponivel ? 'Horário disponível' : 'Horário ocupado'
    });

  } catch (error) {
    console.error('Erro ao verificar disponibilidade:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao verificar disponibilidade',
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
