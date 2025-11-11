const db = require('../config/database');

// Obter saldo
exports.getSaldo = async (req, res) => {
  try {
    const { usuarioId } = req.params;

    // Verificar se o usuário pode acessar esta carteira
    if (req.userId != usuarioId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    const [carteiras] = await db.query(
      'SELECT saldo FROM carteiras WHERE usuario_id = ?',
      [usuarioId]
    );

    if (carteiras.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Carteira não encontrada'
      });
    }

    res.json({
      success: true,
      saldo: parseFloat(carteiras[0].saldo)
    });

  } catch (error) {
    console.error('Erro ao obter saldo:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter saldo',
      error: error.message
    });
  }
};

// Recarregar carteira
exports.recarregar = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const { usuarioId } = req.params;
    const { valor } = req.body;

    // Verificar se o usuário pode recarregar esta carteira
    if (req.userId != usuarioId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    // Validar valor
    if (!valor || valor <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Valor inválido'
      });
    }

    if (valor < 10) {
      return res.status(400).json({
        success: false,
        message: 'Valor mínimo de recarga: R$ 10,00'
      });
    }

    await connection.beginTransaction();

    // Buscar carteira
    const [carteiras] = await connection.query(
      'SELECT id, saldo FROM carteiras WHERE usuario_id = ? FOR UPDATE',
      [usuarioId]
    );

    if (carteiras.length === 0) {
      await connection.rollback();
      return res.status(404).json({
        success: false,
        message: 'Carteira não encontrada'
      });
    }

    const carteira = carteiras[0];
    const saldoAnterior = parseFloat(carteira.saldo);
    const saldoPosterior = saldoAnterior + parseFloat(valor);

    // Atualizar saldo
    await connection.query(
      'UPDATE carteiras SET saldo = ? WHERE id = ?',
      [saldoPosterior, carteira.id]
    );

    // Registrar transação
    await connection.query(
      `INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
       VALUES (?, 'recarga', ?, ?, ?, ?)`,
      [carteira.id, valor, saldoAnterior, saldoPosterior, 'Recarga de créditos']
    );

    await connection.commit();

    res.json({
      success: true,
      message: 'Recarga realizada com sucesso',
      saldo_atual: saldoPosterior
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro ao recarregar carteira:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao recarregar carteira',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Obter transações
exports.getTransacoes = async (req, res) => {
  try {
    const { usuarioId } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    // Verificar se o usuário pode acessar estas transações
    if (req.userId != usuarioId && req.userTipo !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Acesso negado'
      });
    }

    const [transacoes] = await db.query(
      `SELECT t.* FROM transacoes t
       INNER JOIN carteiras c ON c.id = t.carteira_id
       WHERE c.usuario_id = ?
       ORDER BY t.data_transacao DESC
       LIMIT ? OFFSET ?`,
      [usuarioId, parseInt(limit), parseInt(offset)]
    );

    res.json({
      success: true,
      transacoes
    });

  } catch (error) {
    console.error('Erro ao obter transações:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter transações',
      error: error.message
    });
  }
};
