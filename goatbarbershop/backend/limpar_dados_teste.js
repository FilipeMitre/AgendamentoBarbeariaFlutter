const mysql = require('mysql2/promise');

async function limparDadosTeste() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    console.log('Limpando dados de teste...');

    // Limpar agendamentos antigos
    await connection.execute('DELETE FROM agendamentos WHERE data_agendamento < CURDATE()');
    console.log('✅ Agendamentos antigos removidos');

    // Zerar saldos dos barbeiros
    await connection.execute('UPDATE carteiras SET saldo = 0.00 WHERE usuario_id IN (1, 2, 3)');
    console.log('✅ Saldos dos barbeiros zerados');

    // Limpar transações dos barbeiros
    await connection.execute(`
      DELETE FROM transacoes 
      WHERE carteira_id IN (
        SELECT id FROM carteiras WHERE usuario_id IN (1, 2, 3)
      )
    `);
    console.log('✅ Transações dos barbeiros removidas');

    // Verificar agendamentos restantes
    const [agendamentos] = await connection.execute(`
      SELECT a.*, u.nome as cliente_nome, b.nome as barbeiro_nome, s.nome as servico_nome
      FROM agendamentos a
      JOIN usuarios u ON a.cliente_id = u.id
      JOIN usuarios b ON a.barbeiro_id = b.id
      JOIN servicos s ON a.servico_id = s.id
      ORDER BY a.data_agendamento, a.horario
    `);

    console.log('\nAgendamentos restantes:');
    if (agendamentos.length === 0) {
      console.log('Nenhum agendamento encontrado');
    } else {
      agendamentos.forEach(ag => {
        console.log(`- ${ag.barbeiro_nome} - ${ag.servico_nome} - ${ag.data_agendamento} ${ag.horario} - Status: ${ag.status}`);
      });
    }

    // Verificar saldos dos barbeiros
    const [saldos] = await connection.execute(`
      SELECT u.nome, c.saldo
      FROM usuarios u
      JOIN carteiras c ON u.id = c.usuario_id
      WHERE u.tipo_usuario = 'barbeiro'
    `);

    console.log('\nSaldos dos barbeiros:');
    saldos.forEach(s => {
      console.log(`- ${s.nome}: R$ ${parseFloat(s.saldo).toFixed(2)}`);
    });

    await connection.end();
    console.log('\n✅ Limpeza concluída! Agora teste fazer novos agendamentos.');

  } catch (error) {
    console.error('Erro:', error);
  }
}

limparDadosTeste();