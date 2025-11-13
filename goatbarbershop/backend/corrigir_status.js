const mysql = require('mysql2/promise');

async function corrigirStatus() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    // Corrigir status dos agendamentos de hoje que estão vazios
    const [result] = await connection.execute(`
      UPDATE agendamentos 
      SET status = 'confirmado' 
      WHERE data_agendamento = CURDATE() 
      AND (status IS NULL OR status = '')
    `);

    console.log(`${result.affectedRows} agendamentos corrigidos para status 'confirmado'`);

    // Verificar agendamentos de hoje
    const [agendamentos] = await connection.execute(`
      SELECT a.*, u.nome as cliente_nome, b.nome as barbeiro_nome, s.nome as servico_nome
      FROM agendamentos a
      JOIN usuarios u ON a.cliente_id = u.id
      JOIN usuarios b ON a.barbeiro_id = b.id
      JOIN servicos s ON a.servico_id = s.id
      WHERE a.data_agendamento = CURDATE()
      ORDER BY a.horario
    `);

    console.log('\nAgendamentos de hoje:');
    agendamentos.forEach(ag => {
      console.log(`- ${ag.barbeiro_nome} às ${ag.horario} - ${ag.servico_nome} - Status: ${ag.status}`);
    });

    await connection.end();
    console.log('\n✅ Status corrigidos! Agora teste o dashboard do barbeiro.');

  } catch (error) {
    console.error('Erro:', error);
  }
}

corrigirStatus();