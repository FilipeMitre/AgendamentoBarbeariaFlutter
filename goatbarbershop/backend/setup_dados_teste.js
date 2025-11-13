const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function setupDadosTeste() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    console.log('Conectado ao banco de dados...');

    // Verificar se já existe cliente
    const [clientes] = await connection.execute(
      'SELECT id FROM usuarios WHERE tipo_usuario = "cliente" LIMIT 1'
    );

    let clienteId;
    
    if (clientes.length === 0) {
      // Criar cliente de teste
      const senhaHash = await bcrypt.hash('123456', 10);
      
      const [result] = await connection.execute(
        `INSERT INTO usuarios (nome, cpf, email, telefone, senha_hash, tipo_usuario, data_cadastro, ativo) 
         VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)`,
        ['João Silva', '12345678901', 'joao@teste.com', '(11) 99999-9999', senhaHash, 'cliente', 1]
      );
      
      clienteId = result.insertId;
      console.log(`Cliente criado com ID: ${clienteId}`);
      
      // Criar carteira para o cliente
      await connection.execute(
        'INSERT INTO carteiras (usuario_id, saldo) VALUES (?, ?)',
        [clienteId, 1000.00]
      );
      console.log('Carteira criada para o cliente');
    } else {
      clienteId = clientes[0].id;
      console.log(`Usando cliente existente ID: ${clienteId}`);
    }

    // Limpar agendamentos antigos de teste
    await connection.execute('DELETE FROM agendamentos WHERE data_agendamento = CURDATE()');

    // Criar agendamentos para hoje
    const hoje = new Date().toISOString().split('T')[0];
    
    const agendamentos = [
      { barbeiro_id: 1, servico_id: 1, horario: '10:00', valor: 35.00 },
      { barbeiro_id: 1, servico_id: 2, horario: '14:00', valor: 25.00 },
      { barbeiro_id: 2, servico_id: 3, horario: '16:00', valor: 50.00 }
    ];

    for (const ag of agendamentos) {
      await connection.execute(
        `INSERT INTO agendamentos (cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valor_servico, status, data_criacao)
         VALUES (?, ?, ?, ?, ?, ?, 'agendado', NOW())`,
        [clienteId, ag.barbeiro_id, ag.servico_id, hoje, ag.horario, ag.valor]
      );
    }

    console.log(`${agendamentos.length} agendamentos criados para hoje (${hoje})`);

    // Verificar resultado
    const [resultados] = await connection.execute(
      `SELECT a.*, u.nome as cliente_nome, b.nome as barbeiro_nome, s.nome as servico_nome 
       FROM agendamentos a
       JOIN usuarios u ON a.cliente_id = u.id
       JOIN usuarios b ON a.barbeiro_id = b.id  
       JOIN servicos s ON a.servico_id = s.id
       WHERE a.data_agendamento = CURDATE()`
    );

    console.log('\nAgendamentos criados:');
    resultados.forEach(ag => {
      console.log(`- ${ag.barbeiro_nome} às ${ag.horario} - ${ag.servico_nome} - R$ ${ag.valor_servico}`);
    });

    await connection.end();
    console.log('\nDados de teste configurados com sucesso!');
    console.log('Agora teste o login do barbeiro: haku@goatbarber.com / 123456');

  } catch (error) {
    console.error('Erro:', error);
  }
}

setupDadosTeste();