const mysql = require('mysql2/promise');
require('dotenv').config();

async function inserirServicos() {
  let connection;
  
  try {
    // Conectar ao banco
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'goatbarber',
      charset: 'utf8mb4'
    });

    console.log('Conectado ao banco de dados MySQL');

    // Inserir serviços
    const servicos = [
      ['Corte Masculino', 'Corte de cabelo masculino tradicional', 35.00, 30],
      ['Barba', 'Aparar e modelar barba', 25.00, 30],
      ['Corte + Barba (Completo)', 'Pacote completo: corte e barba', 50.00, 60],
      ['Corte Feminino', 'Corte de cabelo feminino', 45.00, 60],
      ['Coloração', 'Tintura e coloração de cabelo', 80.00, 90],
      ['Hidratação', 'Tratamento de hidratação capilar', 60.00, 60],
      ['Escova', 'Escova modeladora', 40.00, 30],
      ['Luzes/Mechas', 'Aplicação de luzes ou mechas', 120.00, 120]
    ];

    for (const [nome, descricao, preco, duracao] of servicos) {
      try {
        await connection.execute(
          `INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos) 
           VALUES (?, ?, ?, ?) 
           ON DUPLICATE KEY UPDATE
           descricao = VALUES(descricao),
           preco_base = VALUES(preco_base),
           duracao_minutos = VALUES(duracao_minutos)`,
          [nome, descricao, preco, duracao]
        );
        console.log(`✓ Serviço inserido/atualizado: ${nome}`);
      } catch (error) {
        console.error(`✗ Erro ao inserir serviço ${nome}:`, error.message);
      }
    }

    // Verificar serviços inseridos
    const [rows] = await connection.execute('SELECT * FROM servicos ORDER BY id');
    console.log('\n=== SERVIÇOS NO BANCO ===');
    rows.forEach(servico => {
      console.log(`${servico.id}: ${servico.nome} - R$ ${servico.preco_base} (${servico.duracao_minutos}min)`);
    });

    console.log('\n✅ Serviços inseridos com sucesso!');

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
  inserirServicos();
}

module.exports = inserirServicos;