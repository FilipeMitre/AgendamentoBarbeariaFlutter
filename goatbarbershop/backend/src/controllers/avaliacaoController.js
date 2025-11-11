const db = require('../config/database');

// Criar avaliação
exports.criarAvaliacao = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const {
      agendamento_id,
      nota_barbearia,
      nota_barbeiro,
      comentario_barbearia,
      comentario_barbeiro
    } = req.body;

    // Validações
    if (!agendamento_id || !nota_barbearia || !nota_barbeiro) {
      return res.status(400).json({
        success: false,
        message: 'Dados incompletos'
      });
    }

    if (nota_barbearia < 1 || nota_barbearia > 5 || nota_barbeiro < 1 || nota_barbeiro > 5) {
      return res.status(400).json({
        success: false,
        message: 'As notas devem estar entre 1 e 5'
      });
    }

    await connection.beginTransaction();

    // Buscar agendamento
    const [agendamentos] = await connection.query(
      'SELECT cliente_id, barbeiro_id, status FROM agendamentos WHERE id = ?',
      [agendamento_id]
    );

    if (agendamentos.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Agendamento não encontrado'
      });
    }

    const agendamento = agendamentos[0];

    // Verificar se é o cliente do agendamento
    if (req.userId != agendamento.cliente_id) {
      await connection.rollback();
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Verificar se agendamento foi concluído
    if (agendamento.status !== 'concluido') {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Só é possível avaliar agendamentos concluídos'
      });
    }

    // Verificar se já existe avaliação
    const [avaliacoesExistentes] = await connection.query(
      'SELECT id FROM avaliacoes WHERE agendamento_id = ?',
      [agendamento_id]
    );

    if (avaliacoesExistentes.length > 0) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Este agendamento já foi avaliado'
      });
    }

    // Criar avaliação
    const [result] = await connection.query(
      `INSERT INTO avaliacoes 
       (agendamento_id, cliente_id, barbeiro_id, nota_barbearia, nota_barbeiro, 
        comentario_barbearia, comentario_barbeiro)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        agendamento_id,
        req.userId,
        agendamento.barbeiro_id,
        nota_barbearia,
        nota_barbeiro,
        comentario_barbearia,
        comentario_barbeiro
      ]
    );

    // Atualizar média de avaliações do barbeiro
    await connection.query(
      `UPDATE usuarios 
       SET avaliacao_media = (
         SELECT AVG(nota_barbeiro) 
         FROM avaliacoes 
         WHERE barbeiro_id = ?
       )
       WHERE id = ?`,
      [agendamento.barbeiro_id, agendamento.barbeiro_id]
    );

    await connection.commit();

    res.status(201).json({
      success: true,
      message: 'Avaliação enviada com sucesso',
      avaliacao_id: result.insertId
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao criar avaliação:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar avaliação',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Obter avaliações de um barbeiro
exports.getAvaliacoesBarbeiro = async (req, res) => {
  try {
    const { barbeiroId } = req.params;
    const { limit = 10, offset = 0 } = req.query;

    const [avaliacoes] = await db.query(
      `SELECT a.*, 
              u.nome as cliente_nome,
              ag.data_agendamento
       FROM avaliacoes a
       INNER JOIN usuarios u ON u.id = a.cliente_id
       INNER JOIN agendamentos ag ON ag.id = a.agendamento_id
       WHERE a.barbeiro_id = ?
       ORDER BY a.data_avaliacao DESC
       LIMIT ? OFFSET ?`,
      [barbeiroId, parseInt(limit), parseInt(offset)]
    );

    // Calcular estatísticas
    const [stats] = await db.query(
      `SELECT 
         COUNT(*) as total_avaliacoes,
         AVG(nota_barbeiro) as media_barbeiro,
         AVG(nota_barbearia) as media_barbearia
       FROM avaliacoes
       WHERE barbeiro_id = ?`,
      [barbeiroId]
    );

    res.json({
      success: true,
      avaliacoes,
      estatisticas: stats[0]
    });

  } catch (error) {
    console.error('Erro ao obter avaliações:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter avaliações',
      error: error.message
    });
  }
};
