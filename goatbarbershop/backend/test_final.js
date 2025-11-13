const mysql = require('mysql2/promise');

(async () => {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: 'learnpro',
      database: 'barbearia_app'
    });

    console.log('\n=== TESTE CORRIGIDO DE HORÁRIOS ===\n');
    
    const barbeiro_id = 2;
    const testDates = [
      { data: '2025-03-11', descricao: 'Segunda-feira' },
      { data: '2025-03-14', descricao: 'Quinta-feira' },
      { data: '2025-03-15', descricao: 'Sexta-feira' },
      { data: '2025-03-16', descricao: 'SÁBADO' },
      { data: '2025-03-17', descricao: 'Domingo' },
    ];

    const diasSemana = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    const nomesDia = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];

    for (const teste of testDates) {
      const dataObj = new Date(teste.data);
      const dayOfWeek = dataObj.getDay();
      const diaSemanaDb = diasSemana[dayOfWeek];
      
      console.log(`\n📅 ${teste.descricao} (${nomesDia[dayOfWeek]})`);
      console.log(`   Data: ${teste.data}, Busca no BD por: "${diaSemanaDb}"`);

      const [disponibilidades] = await connection.query(
        `SELECT horario FROM disponibilidade_barbeiro 
         WHERE barbeiro_id = ? 
         AND dia_semana = ? 
         AND ativo = TRUE
         ORDER BY horario ASC`,
        [barbeiro_id, diaSemanaDb]
      );

      const horarios = disponibilidades.map(d => {
        const hora = String(d.horario).padStart(8, '0');
        return hora.substring(0, 5);
      });

      if (horarios.length === 0) {
        console.log(`   ⚠️  Barbeiro não trabalha neste dia`);
      } else {
        console.log(`   ✅ De ${horarios[0]} até ${horarios[horarios.length - 1]} (${disponibilidades.length} slots)`);
      }
    }

    await connection.end();
  } catch (error) {
    console.error('Erro:', error.message);
  }
})();
