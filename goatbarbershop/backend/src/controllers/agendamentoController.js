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

    // Validação: Barbeiro não pode agendar consigo mesmo
    if (cliente_id === barbeiro_id) {
      return res.status(400).json({
        success: false,
        message: 'Não é permitido agendar um serviço consigo mesmo'
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

    // Usar taxa de comissão padrão do .env ou 5%
    const taxaComissao = parseFloat(process.env.TAXA_COMISSAO) || 5.0;

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

    // Converter data em formato YYYY-MM-DD para objeto Date (sem timezone)
    const [ano, mes, dia] = data.split('-').map(Number);
    const dataAgendamento = new Date(ano, mes - 1, dia);
    
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    
    if (dataAgendamento < hoje) {
      return res.json({
        success: true,
        horarios: [],
        horarios_ocupados: []
      });
    }

    // Determinar dia da semana: getDay() retorna 0=domingo, 1=segunda, ..., 6=sábado
    const diaSemana = dataAgendamento.getDay();
    const diasSemanaNome = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    const diaSemanaStr = diasSemanaNome[diaSemana];

    console.log(`DEBUG: Data: ${data}, Dia semana: ${diaSemanaStr} (index: ${diaSemana})`);

    // Buscar horário de funcionamento da barbearia para este dia
    const [horariosFuncionamento] = await db.query(
      `SELECT horario_abertura, horario_fechamento FROM horarios_funcionamento 
       WHERE dia_semana = ? AND ativo = TRUE`,
      [diaSemanaStr]
    );

    if (horariosFuncionamento.length === 0) {
      console.log(`DEBUG: Nenhum horário de funcionamento encontrado para ${diaSemanaStr}`);
      return res.json({
        success: true,
        horarios: [],
        horarios_ocupados: [],
        message: 'Barbearia não funciona neste dia'
      });
    }

    const horarioAbertura = horariosFuncionamento[0].horario_abertura;
    const horarioFechamento = horariosFuncionamento[0].horario_fechamento;

    console.log(`DEBUG: Barbearia abre às ${horarioAbertura} e fecha às ${horarioFechamento}`);

    // Buscar intervalo de agendamento configurado (em minutos)
    const [configIntervalo] = await db.query(
      `SELECT CAST(valor AS UNSIGNED) as intervalo FROM configuracoes_sistema 
       WHERE chave = 'intervalo_agendamento_minutos' LIMIT 1`
    );
    const intervalloMinutos = configIntervalo.length > 0 ? parseInt(configIntervalo[0].intervalo) : 30;

    // Gerar lista de horários base a partir do intervalo configurado
    const horariosBase = [];
    const [abertura_hora, abertura_min] = horarioAbertura.split(':').map(Number);
    const [fechamento_hora, fechamento_min] = horarioFechamento.split(':').map(Number);
    
    let horaAtual = abertura_hora;
    let minutoAtual = abertura_min;

    while (horaAtual < fechamento_hora || (horaAtual === fechamento_hora && minutoAtual < fechamento_min)) {
      const horarioFormatado = `${String(horaAtual).padStart(2, '0')}:${String(minutoAtual).padStart(2, '0')}`;
      horariosBase.push(horarioFormatado);

      minutoAtual += intervalloMinutos;
      if (minutoAtual >= 60) {
        horaAtual += Math.floor(minutoAtual / 60);
        minutoAtual = minutoAtual % 60;
      }
    }

    console.log('DEBUG: Horários gerados a partir do banco:', horariosBase);

    // Buscar disponibilidade do barbeiro para este dia e hora
    const [disponibilidadeBarbeiro] = await db.query(
      `SELECT horario FROM disponibilidade_barbeiro 
       WHERE barbeiro_id = ? 
       AND dia_semana = ? 
       AND ativo = TRUE
       ORDER BY horario`,
      [barbeiro_id, diaSemanaStr]
    );

    const horariosDisponicaoFormatados = disponibilidadeBarbeiro.map(d => {
      const horario = d.horario;
      if (typeof horario === 'string') {
        return horario.substring(0, 5); // Pegar apenas HH:MM
      }
      return horario;
    });

    console.log(`DEBUG: Barbeiro ${barbeiro_id} tem ${horariosDisponicaoFormatados.length} horários disponíveis:`, horariosDisponicaoFormatados);
    console.log('DEBUG: Horários base gerados:', horariosBase);

    // Filtrar apenas horários onde o barbeiro está disponível
    let horariosValidos = horariosBase.filter(h => horariosDisponicaoFormatados.includes(h));

    console.log('DEBUG: Horários válidos após filtro:', horariosValidos);

    console.log('DEBUG: Horários válidos (após filtrar disponibilidade):', horariosValidos);

    // Buscar agendamentos já marcados
    const [agendamentosOcupados] = await db.query(
      `SELECT horario FROM agendamentos 
       WHERE barbeiro_id = ? 
       AND data_agendamento = ? 
       AND status IN ('confirmado', 'concluido')`,
      [barbeiro_id, data]
    );

    const horariosOcupados = agendamentosOcupados.map(a => {
      const horario = a.horario;
      if (typeof horario === 'string') {
        return horario.substring(0, 5); // Pegar apenas HH:MM
      }
      return horario;
    });
    
    console.log('DEBUG: Horários ocupados encontrados:', horariosOcupados);

    // Se for hoje, filtrar horários que já passaram
    if (dataAgendamento.toDateString() === hoje.toDateString()) {
      const agora = new Date();
      const horaAtual = agora.getHours();
      const minutoAtual = agora.getMinutes();
      
      horariosValidos = horariosValidos.filter(horario => {
        const [hora, minuto] = horario.split(':').map(Number);
        return hora > horaAtual || (hora === horaAtual && minuto > minutoAtual + 30); // 30min de antecedência
      });

      console.log(`DEBUG: Após filtrar horários passados (agora é ${horaAtual}:${minutoAtual}):`, horariosValidos);
    }

    // Remover horários ocupados
    const horariosDisponiveis = horariosValidos.filter(h => !horariosOcupados.includes(h));

    console.log('DEBUG: Horários finalmente disponíveis:', horariosDisponiveis);

    res.json({
      success: true,
      horarios: horariosDisponiveis,
      horarios_ocupados: horariosOcupados,
      intervalo_minutos: intervalloMinutos,
      horario_abertura: horarioAbertura,
      horario_fechamento: horarioFechamento
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

    // Buscar intervalo de agendamento configurado
    const [configIntervalo] = await db.query(
      `SELECT CAST(valor AS UNSIGNED) as intervalo FROM configuracoes_sistema 
       WHERE chave = 'intervalo_agendamento_minutos' LIMIT 1`
    );
    const intervalloMinutos = configIntervalo.length > 0 ? parseInt(configIntervalo[0].intervalo) : 30;

    const diasDisponiveis = [];
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    const diasSemanaNome = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    
    // Gerar próximos 45 dias para garantir 30 dias úteis
    for (let i = 0; i < 45; i++) {
      const data = new Date(hoje);
      data.setDate(hoje.getDate() + i);
      
      const diaSemana = data.getDay();
      // Pular domingos (0 = domingo)
      if (diaSemana === 0) continue;
      
      const diaSemanaStr = diasSemanaNome[diaSemana];

      console.log(`DEBUG getDiasDisponiveis: Processando ${data.toDateString()} - ${diaSemanaStr}`);

      // Buscar horário de funcionamento para este dia
      const [horariosFuncionamento] = await db.query(
        `SELECT horario_abertura, horario_fechamento FROM horarios_funcionamento 
         WHERE dia_semana = ? AND ativo = TRUE`,
        [diaSemanaStr]
      );

      if (horariosFuncionamento.length === 0) {
        console.log(`DEBUG: Sem funcionamento para ${diaSemanaStr}`);
        continue; // Dia não funciona
      }

      const horarioAbertura = horariosFuncionamento[0].horario_abertura;
      const horarioFechamento = horariosFuncionamento[0].horario_fechamento;

      // Calcular total de horários possíveis para este dia
      const [abertura_hora, abertura_min] = horarioAbertura.split(':').map(Number);
      const [fechamento_hora, fechamento_min] = horarioFechamento.split(':').map(Number);
      
      let totalHorariosPossiveis = 0;
      let horaAtual = abertura_hora;
      let minutoAtual = abertura_min;

      while (horaAtual < fechamento_hora || (horaAtual === fechamento_hora && minutoAtual < fechamento_min)) {
        totalHorariosPossiveis++;
        minutoAtual += intervalloMinutos;
        if (minutoAtual >= 60) {
          horaAtual += Math.floor(minutoAtual / 60);
          minutoAtual = minutoAtual % 60;
        }
      }

      // Verificar disponibilidade do barbeiro
      const [disponibilidadeBarbeiro] = await db.query(
        `SELECT COUNT(DISTINCT horario) as total_horarios FROM disponibilidade_barbeiro 
         WHERE barbeiro_id = ? 
         AND dia_semana = ? 
         AND ativo = TRUE`,
        [barbeiro_id, diaSemanaStr]
      );

      let horariosDisponiveis = totalHorariosPossiveis;
      
      // Se for hoje, considerar apenas horários futuros
      const agora = new Date();
      const dataAtual = new Date();
      dataAtual.setHours(0, 0, 0, 0);
      
      if (data.getTime() === dataAtual.getTime()) {
        const horaAtual = agora.getHours();
        const minutoAtual = agora.getMinutes();
        
        // Recalcular horários disponíveis apenas até o fechamento e após horário atual
        horariosDisponiveis = 0;
        let hora = abertura_hora;
        let minuto = abertura_min;
        
        while (hora < fechamento_hora || (hora === fechamento_hora && minuto < fechamento_min)) {
          // Só contar se for no futuro (30min de antecedência)
          if (hora > horaAtual || (hora === horaAtual && minuto > minutoAtual + 30)) {
            horariosDisponiveis++;
          }
          minuto += intervalloMinutos;
          if (minuto >= 60) {
            hora += Math.floor(minuto / 60);
            minuto = minuto % 60;
          }
        }
      }

      // Buscar agendamentos para este dia
      const dataFormatada = data.toISOString().split('T')[0];
      const [agendamentos] = await db.query(
        `SELECT COUNT(*) as total FROM agendamentos 
         WHERE barbeiro_id = ? 
         AND data_agendamento = ? 
         AND status IN ('confirmado', 'concluido')`,
        [barbeiro_id, dataFormatada]
      );

      const totalAgendamentos = agendamentos[0].total;

      // Adicionar se houver horários livres
      if (totalAgendamentos < horariosDisponiveis && disponibilidadeBarbeiro[0].total_horarios > 0) {
        diasDisponiveis.push({
          data: dataFormatada,
          dia_semana: diaSemana,
          horarios_livres: horariosDisponiveis - totalAgendamentos,
          total_horarios_possiveis: horariosDisponiveis
        });
      }

      if (diasDisponiveis.length >= 30) break;
    }

    res.json({
      success: true,
      dias: diasDisponiveis,
      intervalo_minutos: intervalloMinutos
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
    const { barbeiro_id, data_agendamento, horario } = req.query;

    if (!barbeiro_id || !data_agendamento || !horario) {
      return res.status(400).json({
        success: false,
        message: 'Barbeiro, data e horário são obrigatórios'
      });
    }

    // Converter data em formato YYYY-MM-DD
    const [ano, mes, dia] = data_agendamento.split('-').map(Number);
    const dataObj = new Date(ano, mes - 1, dia);
    
    // Verificar se não é no passado
    const agora = new Date();
    agora.setHours(0, 0, 0, 0);
    
    if (dataObj < agora) {
      return res.json({
        success: true,
        disponivel: false,
        message: 'Data no passado'
      });
    }

    // Verificar se é hoje e o horário já passou
    const hoje = new Date();
    const dataAtual = new Date();
    dataAtual.setHours(0, 0, 0, 0);
    
    if (dataObj.getTime() === dataAtual.getTime()) {
      const [horaStr, minutoStr] = horario.split(':').map(Number);
      if (hoje.getHours() > horaStr || (hoje.getHours() === horaStr && hoje.getMinutes() > minutoStr)) {
        return res.json({
          success: true,
          disponivel: false,
          message: 'Horário já passou'
        });
      }
    }

    // Determinar dia da semana
    const diaSemana = dataObj.getDay();
    const diasSemanaNome = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    const diaSemanaStr = diasSemanaNome[diaSemana];

    console.log(`DEBUG verificarDisponibilidade: Data: ${data_agendamento}, DiaSemana: ${diaSemanaStr}, Barbeiro: ${barbeiro_id}, Horário: ${horario}`);

    // Verificar se barbeiro tem disponibilidade neste dia e horário
    const [disponibilidade] = await db.query(
      `SELECT id FROM disponibilidade_barbeiro 
       WHERE barbeiro_id = ? 
       AND dia_semana = ? 
       AND horario = ? 
       AND ativo = TRUE`,
      [barbeiro_id, diaSemanaStr, horario]
    );

    console.log(`DEBUG: Query resultado - Encontrados ${disponibilidade.length} registros`);

    // Verificar se já está ocupado
    const [agendamentos] = await db.query(
      `SELECT id FROM agendamentos 
       WHERE barbeiro_id = ? 
       AND data_agendamento = ? 
       AND horario = ? 
       AND status IN ('confirmado', 'concluido')`,
      [barbeiro_id, data_agendamento, horario]
    );

    const disponivel = agendamentos.length === 0;

    console.log(`DEBUG: Verificação de disponibilidade - Barbeiro: ${barbeiro_id}, Data: ${data_agendamento}, Horário: ${horario}, Disponível: ${disponivel}`);

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

// Obter serviços ativos
exports.getServicosAtivos = async (req, res) => {
  try {
    const [servicos] = await db.query(
      `SELECT id, nome, descricao, preco_base, duracao_minutos 
       FROM servicos 
       WHERE ativo = TRUE 
       ORDER BY nome`
    );

    res.json({
      success: true,
      servicos
    });

  } catch (error) {
    console.error('Erro ao obter serviços ativos:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter serviços',
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
