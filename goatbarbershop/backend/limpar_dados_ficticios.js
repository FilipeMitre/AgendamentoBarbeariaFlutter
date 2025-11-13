const mysql = require('mysql2/promise');

async function limparDadosFicticios() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    console.log('Limpando dados fictícios...');

    // Limpar transações
    await connection.execute('DELETE FROM transacoes');
    console.log('✓ Transações removidas');

    // Limpar agendamentos
    await connection.execute('DELETE FROM agendamentos');
    console.log('✓ Agendamentos removidos');

    // Limpar produtos fictícios
    await connection.execute('DELETE FROM produtos');
    console.log('✓ Produtos removidos');

    // Limpar categorias fictícias
    await connection.execute('DELETE FROM categorias_produto');
    console.log('✓ Categorias removidas');

    // Limpar usuários fictícios (manter apenas admin real)
    await connection.execute('DELETE FROM usuarios WHERE id != 9008');
    console.log('✓ Usuários fictícios removidos (admin mantido)');

    // Limpar carteiras
    await connection.execute('DELETE FROM carteiras WHERE usuario_id != 9008');
    console.log('✓ Carteiras fictícias removidas');

    // Limpar serviços fictícios
    await connection.execute('DELETE FROM servicos');
    console.log('✓ Serviços fictícios removidos');

    // Reset auto increment
    await connection.execute('ALTER TABLE usuarios AUTO_INCREMENT = 9009');
    await connection.execute('ALTER TABLE agendamentos AUTO_INCREMENT = 1');
    await connection.execute('ALTER TABLE servicos AUTO_INCREMENT = 1');
    await connection.execute('ALTER TABLE produtos AUTO_INCREMENT = 1');
    await connection.execute('ALTER TABLE categorias_produto AUTO_INCREMENT = 1');
    await connection.execute('ALTER TABLE transacoes AUTO_INCREMENT = 1');
    await connection.execute('ALTER TABLE carteiras AUTO_INCREMENT = 2');

    console.log('✓ Sistema limpo e pronto para uso real');
    console.log('\nAdmin disponível:');
    console.log('Email: admin@goatbarber.com');
    console.log('Senha: admin123');

    await connection.end();
  } catch (error) {
    console.error('Erro:', error);
  }
}

limparDadosFicticios();