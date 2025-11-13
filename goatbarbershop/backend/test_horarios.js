const mysql = require('mysql2/promise');

(async () => {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: 'learnpro',
      database: 'barbearia_app'
    });

    console.log('\n=== HORÁRIOS DE DISPONIBILIDADE POR BARBEIRO E DIA ===\n');
    
    for (let barbeiro = 2; barbeiro <= 4; barbeiro++) {
      console.log(`\n📅 BARBEIRO ID ${barbeiro}:`);
      const [rows] = await connection.query(
        `SELECT DISTINCT dia_semana, COUNT(*) as total_horarios, 
                MIN(TIME_FORMAT(horario, '%H:%i')) as primeiro, 
                MAX(TIME_FORMAT(horario, '%H:%i')) as ultimo 
         FROM disponibilidade_barbeiro 
         WHERE barbeiro_id = ? 
         GROUP BY dia_semana 
         ORDER BY FIELD(dia_semana, 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado')`,
        [barbeiro]
      );
      
      rows.forEach(row => {
        console.log(`  ${row.dia_semana.padEnd(10)} → ${row.primeiro} até ${row.ultimo} (${row.total_horarios} slots)`);
      });
    }

    await connection.end();
  } catch (error) {
    console.error('Erro:', error.message);
  }
})();
