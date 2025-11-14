const db = require('../config/database');
const { hashPassword, comparePassword, generateToken, validarCPF } = require('../utils/helpers');

// Obter estatísticas do painel administrativo
exports.getEstatisticasAdmin = async (req, res) => {
  try {
    const [totalUsuarios] = await db.query('SELECT COUNT(*) as count FROM usuarios');
    const [totalAgendamentos] = await db.query('SELECT COUNT(*) as count FROM agendamentos');
    const [receitaTotal] = await db.query(
      `SELECT SUM(valor) as total FROM transacoes WHERE tipo_transacao = 'pagamento'`
    );
    const [totalProdutos] = await db.query('SELECT COUNT(*) as count FROM produtos');

    res.json({
      success: true,
      total_usuarios: totalUsuarios[0].count,
      total_agendamentos: totalAgendamentos[0].count,
      receita_total: parseFloat(receitaTotal[0].total || 0),
      total_produtos: totalProdutos[0].count
    });

  } catch (error) {
    console.error('Erro ao obter estatísticas do admin:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter estatísticas',
      error: error.message
    });
  }
};

// Gerenciar Usuários
exports.getUsuarios = async (req, res) => {
  try {
    console.log('DEBUG: Buscando usuários...');
    const [usuarios] = await db.query(
      `SELECT id, nome, email, telefone, cpf, tipo_usuario, ativo, data_cadastro 
       FROM usuarios ORDER BY data_cadastro DESC`
    );
    
    console.log('DEBUG: Usuários encontrados:', usuarios.length);
    console.log('DEBUG: Primeiros 3 usuários:', usuarios.slice(0, 3));

    res.json({
      success: true,
      usuarios
    });

  } catch (error) {
    console.error('Erro ao obter usuários (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter usuários',
      error: error.message
    });
  }
};

exports.atualizarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { tipo_usuario, ativo } = req.body;

    // Validações
    if (!tipo_usuario || typeof ativo !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'Tipo de usuário e status ativo são obrigatórios'
      });
    }
    if (!['cliente', 'barbeiro', 'admin'].includes(tipo_usuario)) {
      return res.status(400).json({
        success: false,
        message: 'Tipo de usuário inválido'
      });
    }

    const [result] = await db.query(
      `UPDATE usuarios SET tipo_usuario = ?, ativo = ? WHERE id = ?`,
      [tipo_usuario, ativo, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Usuário não encontrado'
      });
    }

    const [updatedUser] = await db.query(
      `SELECT id, nome, email, telefone, cpf, tipo_usuario, ativo, data_cadastro 
       FROM usuarios WHERE id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Usuário atualizado com sucesso',
      usuario: updatedUser[0]
    });

  } catch (error) {
    console.error('Erro ao atualizar usuário (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar usuário',
      error: error.message
    });
  }
};

// Gerenciar Serviços
exports.getServicos = async (req, res) => {
  try {
    const [servicos] = await db.query(
      `SELECT id, nome, descricao, preco_base, duracao_minutos, ativo 
       FROM servicos ORDER BY nome`
    );

    res.json({
      success: true,
      servicos
    });

  } catch (error) {
    console.error('Erro ao obter serviços (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter serviços',
      error: error.message
    });
  }
};

exports.adicionarServico = async (req, res) => {
  try {
    const { nome, descricao, preco_base, duracao_minutos } = req.body;

    if (!nome || !preco_base || !duracao_minutos) {
      return res.status(400).json({
        success: false,
        message: 'Nome, preço base e duração são obrigatórios'
      });
    }
    if (preco_base <= 0 || duracao_minutos <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Preço e duração devem ser maiores que zero'
      });
    }

    const [result] = await db.query(
      `INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos)
       VALUES (?, ?, ?, ?)`,
      [nome, descricao, preco_base, duracao_minutos]
    );

    const [newServico] = await db.query(
      `SELECT id, nome, descricao, preco_base, duracao_minutos, ativo 
       FROM servicos WHERE id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Serviço adicionado com sucesso',
      servico: newServico[0]
    });

  } catch (error) {
    console.error('Erro ao adicionar serviço (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao adicionar serviço',
      error: error.message
    });
  }
};

exports.atualizarServico = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, descricao, preco_base, duracao_minutos, ativo } = req.body;

    if (!nome || !preco_base || !duracao_minutos || typeof ativo !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'Nome, preço base, duração e status ativo são obrigatórios'
      });
    }
    if (preco_base <= 0 || duracao_minutos <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Preço e duração devem ser maiores que zero'
      });
    }

    const [result] = await db.query(
      `UPDATE servicos SET nome = ?, descricao = ?, preco_base = ?, duracao_minutos = ?, ativo = ? WHERE id = ?`,
      [nome, descricao, preco_base, duracao_minutos, ativo, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Serviço não encontrado'
      });
    }

    const [updatedServico] = await db.query(
      `SELECT id, nome, descricao, preco_base, duracao_minutos, ativo 
       FROM servicos WHERE id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Serviço atualizado com sucesso',
      servico: updatedServico[0]
    });

  } catch (error) {
    console.error('Erro ao atualizar serviço (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar serviço',
      error: error.message
    });
  }
};

// Gerenciar Produtos
exports.getProdutosAdmin = async (req, res) => {
  try {
    console.log('[DEBUG] getProdutosAdmin called by userId=', req.userId, 'userTipo=', req.userTipo);
    const [produtos] = await db.query(
      `SELECT p.id, p.nome, p.descricao, p.preco, p.estoque, p.imagem_url, p.ativo, p.destaque,
              cp.nome as categoria_nome, cp.tipo as categoria_tipo
       FROM produtos p
       INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
       ORDER BY p.nome`
    );

    res.json({
      success: true,
      produtos
    });

    console.log('[DEBUG] getProdutosAdmin returned produtos count=', produtos.length);

  } catch (error) {
    console.error('Erro ao obter produtos (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter produtos',
      error: error.message
    });
  }
};

exports.adicionarProduto = async (req, res) => {
  try {
    const { categoria_id, nome, descricao, preco, estoque, imagem_url, destaque } = req.body;

    if (!categoria_id || !nome || !preco || !estoque) {
      return res.status(400).json({
        success: false,
        message: 'Categoria, nome, preço e estoque são obrigatórios'
      });
    }
    if (preco <= 0 || estoque < 0) {
      return res.status(400).json({
        success: false,
        message: 'Preço deve ser maior que zero e estoque não pode ser negativo'
      });
    }

    const [result] = await db.query(
      `INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, imagem_url, destaque)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [categoria_id, nome, descricao, preco, estoque, imagem_url, destaque || false]
    );

    const [newProduto] = await db.query(
      `SELECT p.id, p.nome, p.descricao, p.preco, p.estoque, p.imagem_url, p.ativo, p.destaque,
              cp.nome as categoria_nome, cp.tipo as categoria_tipo
       FROM produtos p
       INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
       WHERE p.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Produto adicionado com sucesso',
      produto: newProduto[0]
    });

  } catch (error) {
    console.error('Erro ao adicionar produto (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao adicionar produto',
      error: error.message
    });
  }
};

exports.atualizarProduto = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, descricao, preco, estoque, imagem_url, ativo, destaque } = req.body;

    if (!nome || !preco || typeof estoque === 'undefined' || typeof ativo !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'Nome, preço, estoque e status ativo são obrigatórios'
      });
    }
    if (preco <= 0 || estoque < 0) {
      return res.status(400).json({
        success: false,
        message: 'Preço deve ser maior que zero e estoque não pode ser negativo'
      });
    }

    const [result] = await db.query(
      `UPDATE produtos SET nome = ?, descricao = ?, preco = ?, estoque = ?, imagem_url = ?, ativo = ?, destaque = ? WHERE id = ?`,
      [nome, descricao, preco, estoque, imagem_url, ativo, destaque, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Produto não encontrado'
      });
    }

    const [updatedProduto] = await db.query(
      `SELECT p.id, p.nome, p.descricao, p.preco, p.estoque, p.imagem_url, p.ativo, p.destaque,
              cp.nome as categoria_nome, cp.tipo as categoria_tipo
       FROM produtos p
       INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
       WHERE p.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Produto atualizado com sucesso',
      produto: updatedProduto[0]
    });

  } catch (error) {
    console.error('Erro ao atualizar produto (admin):', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar produto',
      error: error.message
    });
  }
};

// Gerenciar Categorias de Produtos
exports.getCategoriasProduto = async (req, res) => {
  try {
    const [categorias] = await db.query(
      `SELECT id, nome, descricao, tipo, ativo FROM categorias_produto ORDER BY nome`
    );
    res.json({ success: true, categorias });
  } catch (error) {
    console.error('Erro ao obter categorias de produto:', error);
    res.status(500).json({ success: false, message: 'Erro ao obter categorias', error: error.message });
  }
};

exports.adicionarCategoriaProduto = async (req, res) => {
  try {
    const { nome, descricao, tipo } = req.body;
    if (!nome || !tipo) {
      return res.status(400).json({ success: false, message: 'Nome e tipo são obrigatórios' });
    }
    if (!['produto', 'bebida'].includes(tipo)) {
      return res.status(400).json({ success: false, message: 'Tipo inválido. Deve ser "produto" ou "bebida".' });
    }
    const [result] = await db.query(
      `INSERT INTO categorias_produto (nome, descricao, tipo) VALUES (?, ?, ?)`,
      [nome, descricao, tipo]
    );
    res.status(201).json({ success: true, message: 'Categoria adicionada', id: result.insertId });
  } catch (error) {
    console.error('Erro ao adicionar categoria de produto:', error);
    res.status(500).json({ success: false, message: 'Erro ao adicionar categoria', error: error.message });
  }
};

exports.atualizarCategoriaProduto = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, descricao, tipo, ativo } = req.body;
    if (!nome || !tipo || typeof ativo !== 'boolean') {
      return res.status(400).json({ success: false, message: 'Nome, tipo e status ativo são obrigatórios' });
    }
    if (!['produto', 'bebida'].includes(tipo)) {
      return res.status(400).json({ success: false, message: 'Tipo inválido. Deve ser "produto" ou "bebida".' });
    }
    const [result] = await db.query(
      `UPDATE categorias_produto SET nome = ?, descricao = ?, tipo = ?, ativo = ? WHERE id = ?`,
      [nome, descricao, tipo, ativo, id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Categoria não encontrada' });
    }
    res.json({ success: true, message: 'Categoria atualizada' });
  } catch (error) {
    console.error('Erro ao atualizar categoria de produto:', error);
    res.status(500).json({ success: false, message: 'Erro ao atualizar categoria', error: error.message });
  }
};
