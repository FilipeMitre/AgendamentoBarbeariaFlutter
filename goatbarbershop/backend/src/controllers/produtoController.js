const db = require('../config/database');

// Obter todos os produtos (para clientes)
exports.getProdutos = async (req, res) => {
  try {
    const [produtos] = await db.query(
      `SELECT p.id, p.nome, p.descricao, p.preco, p.estoque, p.imagem_url, p.destaque,
              cp.nome as categoria_nome, cp.tipo as categoria_tipo
       FROM produtos p
       INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
       WHERE p.ativo = TRUE AND p.estoque > 0
       ORDER BY p.destaque DESC, p.nome`
    );

    res.json({
      success: true,
      produtos
    });

  } catch (error) {
    console.error('Erro ao obter produtos:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter produtos',
      error: error.message
    });
  }
};

// Obter bebidas (para clientes)
exports.getBebidas = async (req, res) => {
  try {
    const [bebidas] = await db.query(
      `SELECT p.id, p.nome, p.descricao, p.preco, p.estoque, p.imagem_url, p.destaque,
              cp.nome as categoria_nome, cp.tipo as categoria_tipo
       FROM produtos p
       INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
       WHERE p.ativo = TRUE AND p.estoque > 0 AND cp.tipo = 'bebida'
       ORDER BY p.destaque DESC, p.nome`
    );

    res.json({
      success: true,
      bebidas
    });

  } catch (error) {
    console.error('Erro ao obter bebidas:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter bebidas',
      error: error.message
    });
  }
};

// Obter um produto por ID
exports.getProdutoById = async (req, res) => {
  try {
    const { id } = req.params;

    const [produtos] = await db.query(
      `SELECT p.id, p.nome, p.descricao, p.preco, p.estoque, p.imagem_url, p.destaque,
              cp.nome as categoria_nome, cp.tipo as categoria_tipo
       FROM produtos p
       INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
       WHERE p.id = ? AND p.ativo = TRUE AND p.estoque > 0`,
      [id]
    );

    if (produtos.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Produto não encontrado ou inativo'
      });
    }

    res.json({
      success: true,
      produto: produtos[0]
    });

  } catch (error) {
    console.error('Erro ao obter produto por ID:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter produto',
      error: error.message
    });
  }
};
