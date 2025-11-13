const mysql = require('mysql2/promise');

async function criarAgendamentosTeste() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    // Criar alguns agendamentos para hoje
    const hoje = new Date();
    const dataHoje = hoje.toISOString().split('T')[0];

    const agendamentos = [
      {
        cliente_id: 4, // Assumindo que existe um cliente com ID 4
        barbeiro_id: 1, // Haku Santos
        servico_id: 1, // Corte Masculino
        data_agendamento: dataHoje,
        horario: '10:00',
        valor_servico: 35.00,
        status: 'agendado'
      },
      {
        cliente_id: 4,
        barbeiro_id: 1,
        servico_id: 2, // Barba
        data_agendamento: dataHoje,
        horario: '14:00',
        valor_servico: 25.00,
        status: 'agendado'
      },
      {
        cliente_id: 4,
        barbeiro_id: 2, // Luon Yog
        servico_id: 3, // Corte + Barba
        data_agendamento: dataHoje,
        horario: '16:00',
        valor_servico: 50.00,
        status: 'agendado'
      }
    ];

    for (const agendamento of agendamentos) {
      await connection.execute(
        `INSERT INTO agendamentos 
         (cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valor_servico, status, data_criacao)
         VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
        [
          agendamento.cliente_id,
          agendamento.barbeiro_id,
          agendamento.servico_id,
          agendamento.data_agendamento,
          agendamento.horario,
          agendamento.valor_servico,
          agendamento.status
        ]
      );
    }

    console.log('Agendamentos de teste criados com sucesso!');
    console.log(`Data: ${dataHoje}`);
    console.log('Agendamentos:');
    agendamentos.forEach(a => {
      console.log(`- Barbeiro ${a.barbeiro_id} às ${a.horario} - R$ ${a.valor_servico}`);
    });

    await connection.end();
  } catch (error) {
    console.error('Erro:', error);
  }
}

criarAgendamentosTeste();