const mysql = require('mysql2/promise');

async function resetCompleto() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    console.log('🧹 RESET COMPLETO - Limpando TODOS os dados...');

    // 1. Limpar todas as transações
    await connection.execute('DELETE FROM transacoes');
    console.log('✅ Transações removidas');

    // 2. Limpar todos os agendamentos
    await connection.execute('DELETE FROM agendamentos');
    console.log('✅ Agendamentos removidos');

    // 3. Zerar saldos de todas as carteiras
    await connection.execute('UPDATE carteiras SET saldo = 0.00');
    console.log('✅ Saldos zerados');

    // 4. Verificar barbeiros
    const [barbeiros] = await connection.execute(`
      SELECT u.id, u.nome, c.saldo
      FROM usuarios u
      LEFT JOIN carteiras c ON u.id = c.usuario_id
      WHERE u.tipo_usuario = 'barbeiro'
    `);

    console.log('\n👨‍💼 Barbeiros no sistema:');
    barbeiros.forEach(b => {
      console.log(`- ID: ${b.id} | Nome: ${b.nome} | Saldo: R$ ${(b.saldo || 0).toFixed(2)}`);
    });

    // 5. Verificar clientes
    const [clientes] = await connection.execute(`
      SELECT u.id, u.nome, c.saldo
      FROM usuarios u
      LEFT JOIN carteiras c ON u.id = c.usuario_id
      WHERE u.tipo_usuario = 'cliente'
      LIMIT 3
    `);

    console.log('\n👤 Clientes no sistema:');
    clientes.forEach(c => {
      console.log(`- ID: ${c.id} | Nome: ${c.nome} | Saldo: R$ ${(c.saldo || 0).toFixed(2)}`);
    });

    // 6. Verificar serviços
    const [servicos] = await connection.execute(`
      SELECT id, nome, preco_base
      FROM servicos
      WHERE ativo = 1
    `);

    console.log('\n💇 Serviços disponíveis:');
    servicos.forEach(s => {
      console.log(`- ID: ${s.id} | ${s.nome} | R$ ${s.preco_base}`);
    });

    await connection.end();
    console.log('\n✅ RESET COMPLETO! Sistema limpo e pronto para testes reais.');
    console.log('\n🧪 PRÓXIMOS PASSOS:');
    console.log('1. Faça login como cliente e recarregue a carteira');
    console.log('2. Crie um agendamento real');
    console.log('3. Faça login como barbeiro e veja o agendamento');
    console.log('4. Conclua o agendamento e veja o pagamento');

  } catch (error) {
    console.error('❌ Erro:', error);
  }
}

resetCompleto();