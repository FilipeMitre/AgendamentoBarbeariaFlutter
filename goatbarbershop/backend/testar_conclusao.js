const mysql = require('mysql2/promise');

async function testarConclusao() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    // Buscar agendamentos confirmados
    const [agendamentos] = await connection.execute(
      `SELECT a.*, u.nome as cliente_nome, b.nome as barbeiro_nome, s.nome as servico_nome
       FROM agendamentos a
       JOIN usuarios u ON a.cliente_id = u.id
       JOIN usuarios b ON a.barbeiro_id = b.id
       JOIN servicos s ON a.servico_id = s.id
       WHERE a.status = 'confirmado'
       ORDER BY a.data_agendamento, a.horario`
    );

    console.log('Agendamentos confirmados:');
    agendamentos.forEach(ag => {
      console.log(`ID: ${ag.id} - ${ag.barbeiro_nome} - ${ag.servico_nome} - ${ag.data_agendamento} ${ag.horario} - R$ ${ag.valor_servico}`);
    });

    if (agendamentos.length > 0) {
      const agendamentoTeste = agendamentos[0];
      console.log(`\nTestando conclusão do agendamento ID: ${agendamentoTeste.id}`);

      // Simular conclusão
      await connection.beginTransaction();

      // Atualizar status
      await connection.execute(
        'UPDATE agendamentos SET status = "concluido", data_conclusao = NOW() WHERE id = ?',
        [agendamentoTeste.id]
      );

      // Calcular valores
      const valorServico = parseFloat(agendamentoTeste.valor_servico);
      const taxaComissao = 5.0; // 5%
      const valorComissao = (valorServico * taxaComissao) / 100;
      const valorBarbeiro = valorServico - valorComissao;

      console.log(`Valor serviço: R$ ${valorServico}`);
      console.log(`Comissão (5%): R$ ${valorComissao}`);
      console.log(`Valor barbeiro: R$ ${valorBarbeiro}`);

      // Buscar carteira do barbeiro
      const [carteiras] = await connection.execute(
        'SELECT id, saldo FROM carteiras WHERE usuario_id = ?',
        [agendamentoTeste.barbeiro_id]
      );

      if (carteiras.length === 0) {
        // Criar carteira se não existir
        await connection.execute(
          'INSERT INTO carteiras (usuario_id, saldo) VALUES (?, ?)',
          [agendamentoTeste.barbeiro_id, valorBarbeiro]
        );
        console.log('Carteira criada para o barbeiro');
      } else {
        // Atualizar saldo
        const carteiraId = carteiras[0].id;
        const saldoAnterior = parseFloat(carteiras[0].saldo);
        const saldoPosterior = saldoAnterior + valorBarbeiro;

        await connection.execute(
          'UPDATE carteiras SET saldo = ? WHERE id = ?',
          [saldoPosterior, carteiraId]
        );

        // Registrar transação
        await connection.execute(
          `INSERT INTO transacoes 
           (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
           VALUES (?, 'recebimento', ?, ?, ?, ?)`,
          [
            carteiraId,
            valorBarbeiro,
            saldoAnterior,
            saldoPosterior,
            `Pagamento do agendamento #${agendamentoTeste.id}`
          ]
        );

        console.log(`Saldo anterior: R$ ${saldoAnterior}`);
        console.log(`Saldo posterior: R$ ${saldoPosterior}`);
      }

      await connection.commit();
      console.log('✅ Conclusão simulada com sucesso!');
    } else {
      console.log('Nenhum agendamento confirmado encontrado');
    }

    await connection.end();
  } catch (error) {
    console.error('Erro:', error);
  }
}

testarConclusao();