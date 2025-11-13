const mysql = require('mysql2/promise');
require('dotenv').config();

async function inserirProdutos() {
  let connection;
  
  try {
    // Conectar ao banco
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'barbearia_app',
      charset: 'utf8mb4'
    });

    console.log('Conectado ao banco de dados MySQL');

    // Primeiro, inserir categorias se não existirem
    const categorias = [
      ['Produtos de Cabelo', 'Produtos para cuidados capilares', 'produto'],
      ['Bebidas', 'Bebidas e refrescos', 'bebida'],
      ['Acessórios', 'Acessórios para barbearia', 'produto']
    ];

    for (const [nome, descricao, tipo] of categorias) {
      try {
        await connection.execute(
          `INSERT INTO categorias_produto (nome, descricao, tipo) 
           VALUES (?, ?, ?) 
           ON DUPLICATE KEY UPDATE
           descricao = VALUES(descricao),
           tipo = VALUES(tipo)`,
          [nome, descricao, tipo]
        );
        console.log(`✓ Categoria inserida/atualizada: ${nome}`);
      } catch (error) {
        console.error(`✗ Erro ao inserir categoria ${nome}:`, error.message);
      }
    }

    // Obter IDs das categorias
    const [categoriaRows] = await connection.execute('SELECT id, nome, tipo FROM categorias_produto');
    const categoriaMap = {};
    categoriaRows.forEach(cat => {
      categoriaMap[cat.nome] = cat.id;
    });

    // Inserir produtos
    const produtos = [
      [categoriaMap['Produtos de Cabelo'], 'Shampoo Anticaspa', 'Shampoo para tratamento de caspa', 25.90, 15, null, false],
      [categoriaMap['Produtos de Cabelo'], 'Condicionador Hidratante', 'Condicionador para cabelos ressecados', 22.50, 12, null, false],
      [categoriaMap['Produtos de Cabelo'], 'Pomada Modeladora', 'Pomada para modelar cabelo masculino', 35.00, 8, null, true],
      [categoriaMap['Produtos de Cabelo'], 'Gel Fixador', 'Gel para fixação de penteados', 18.90, 20, null, false],
      [categoriaMap['Produtos de Cabelo'], 'Óleo para Barba', 'Óleo hidratante para barba', 45.00, 6, null, true],
      [categoriaMap['Bebidas'], 'Água Mineral', 'Água mineral 500ml', 3.50, 50, null, false],
      [categoriaMap['Bebidas'], 'Refrigerante Coca-Cola', 'Coca-Cola lata 350ml', 5.00, 30, null, false],
      [categoriaMap['Bebidas'], 'Suco de Laranja', 'Suco natural de laranja 300ml', 8.00, 15, null, false],
      [categoriaMap['Bebidas'], 'Café Expresso', 'Café expresso tradicional', 4.50, 25, null, true],
      [categoriaMap['Acessórios'], 'Pente Profissional', 'Pente para corte profissional', 15.00, 10, null, false]
    ];

    for (const [categoria_id, nome, descricao, preco, estoque, imagem_url, destaque] of produtos) {
      try {
        await connection.execute(
          `INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, imagem_url, destaque) 
           VALUES (?, ?, ?, ?, ?, ?, ?) 
           ON DUPLICATE KEY UPDATE
           descricao = VALUES(descricao),
           preco = VALUES(preco),
           estoque = VALUES(estoque),
           destaque = VALUES(destaque)`,
          [categoria_id, nome, descricao, preco, estoque, imagem_url, destaque]
        );
        console.log(`✓ Produto inserido/atualizado: ${nome}`);
      } catch (error) {
        console.error(`✗ Erro ao inserir produto ${nome}:`, error.message);
      }
    }

    // Verificar produtos inseridos
    const [rows] = await connection.execute(`
      SELECT p.id, p.nome, p.preco, p.estoque, cp.nome as categoria_nome, cp.tipo as categoria_tipo
      FROM produtos p
      INNER JOIN categorias_produto cp ON cp.id = p.categoria_id
      ORDER BY p.id
    `);
    
    console.log('\n=== PRODUTOS NO BANCO ===');
    rows.forEach(produto => {
      console.log(`${produto.id}: ${produto.nome} - R$ ${produto.preco} (Estoque: ${produto.estoque}) - ${produto.categoria_nome}`);
    });

    console.log('\n✅ Produtos inseridos com sucesso!');

  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Executar se chamado diretamente
if (require.main === module) {
  inserirProdutos();
}

module.exports = inserirProdutos;