#!/usr/bin/env node
const pool = require('../src/config/database');
require('dotenv').config();

const DB_NAME = process.env.DB_NAME || 'barbearia_app';
const TARGET_COLLATION = 'utf8mb4_unicode_ci';

(async () => {
  try {
    console.log(`Inspecionando banco: ${DB_NAME} (target collation: ${TARGET_COLLATION})`);

    // Colunas com collation diferente
    const [cols] = await pool.query(
      `SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, COLLATION_NAME
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = ? AND COLLATION_NAME IS NOT NULL AND COLLATION_NAME != ?
       ORDER BY TABLE_NAME, COLUMN_NAME`,
      [DB_NAME, TARGET_COLLATION]
    );

    if (cols.length === 0) {
      console.log('\nNenhuma coluna com collation diferente encontrada.');
    } else {
      console.log('\nColunas com collation diferente:');
      console.table(cols);

      const tables = [...new Set(cols.map(c => c.TABLE_NAME))];
      console.log('\nSugestão de ALTER TABLE para padronizar (execute com backup):');
      tables.forEach(t => console.log(`ALTER TABLE \`${t}\` CONVERT TO CHARACTER SET utf8mb4 COLLATE ${TARGET_COLLATION};`));
    }

    // Tabelas com collation diferente
    const [tables] = await pool.query(
      `SELECT TABLE_NAME, TABLE_COLLATION
       FROM information_schema.TABLES
       WHERE TABLE_SCHEMA = ? AND TABLE_COLLATION != ?
       ORDER BY TABLE_NAME`,
      [DB_NAME, TARGET_COLLATION]
    );

    if (tables.length === 0) {
      console.log('\nNenhuma tabela com collation diferente encontrada.');
    } else {
      console.log('\nTabelas com collation diferente:');
      console.table(tables);
    }

    // Mostrar variáveis relevantes do servidor (para contexto)
    const [vars] = await pool.query(`SHOW VARIABLES LIKE 'collation%';`);
    console.log('\nVariáveis de collation do servidor:');
    console.table(vars);

    const [cs] = await pool.query(`SHOW VARIABLES LIKE 'character_set%';`);
    console.log('\nVariáveis de character_set do servidor:');
    console.table(cs);

  } catch (err) {
    console.error('Erro ao inspecionar collations:', err.message || err);
  } finally {
    try { await pool.end(); } catch (e) {}
    process.exit(0);
  }
})();
