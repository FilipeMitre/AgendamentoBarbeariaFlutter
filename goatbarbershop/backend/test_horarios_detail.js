const mysql = require('mysql2/promise');

(async () => {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: 'learnpro',
      database: 'barbearia_app'
    });

    console.log('\n=== TESTE DE HORÁRIOS PARA DATAS ESPECÍFICAS ===\n');
    
    const barbeiro_id = 2;
    const testDates = [
      { data: '2025-03-11', descricao: 'Segunda-feira (11 de Março)' },      // 2 = Monday
      { data: '2025-03-15', descricao: 'Sábado (15 de Março)' },             // 6 = Saturday
      { data: '2025-03-10', descricao: 'Domingo (10 de Março)' },            // 0 = Sunday
    ];

    const diasSemana = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];

    for (const teste of testDates) {
      const dataObj = new Date(teste.data);
      const diaSemanaDb = diasSemana[dataObj.getDay()];
      
      console.log(`\n📅 ${teste.descricao}`);
      console.log(`   Data: ${teste.data}, Dia da semana no BD: ${diaSemanaDb}`);

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
        console.log(`   ⚠️  Barbeiro não trabalha neste dia (${disponibilidades.length} slots)`);
      } else {
        console.log(`   ✅ ${horarios[0]} até ${horarios[horarios.length - 1]} (${disponibilidades.length} slots)`);
        console.log(`   ${horarios.slice(0, 8).join(', ')}... ${horarios.slice(-2).join(', ')}`);
      }
    }

    await connection.end();
  } catch (error) {
    console.error('Erro:', error.message);
  }
})();
