#!/usr/bin/env node
const pool = require('../src/config/database');
const readline = require('readline');
require('dotenv').config();

const DB_NAME = process.env.DB_NAME || 'barbearia_app';
const TARGET_COLLATION = 'utf8mb4_unicode_ci';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(prompt) {
  return new Promise((resolve) => {
    rl.question(prompt, (answer) => {
      resolve(answer);
    });
  });
}

(async () => {
  try {
    console.log(`\n🔍 Inspecionando banco: ${DB_NAME}`);
    console.log(`   Target collation: ${TARGET_COLLATION}\n`);

    // Colunas com collation diferente
    const [cols] = await pool.query(
      `SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, COLLATION_NAME
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = ? AND COLLATION_NAME IS NOT NULL AND COLLATION_NAME != ?
       ORDER BY TABLE_NAME, COLUMN_NAME`,
      [DB_NAME, TARGET_COLLATION]
    );

    // Tabelas com collation diferente
    const [tables] = await pool.query(
      `SELECT TABLE_NAME, TABLE_COLLATION
       FROM information_schema.TABLES
       WHERE TABLE_SCHEMA = ? AND TABLE_COLLATION != ?
       ORDER BY TABLE_NAME`,
      [DB_NAME, TARGET_COLLATION]
    );

    if (cols.length === 0 && tables.length === 0) {
      console.log('✅ Nenhuma coluna ou tabela com collation diferente encontrada.');
      rl.close();
      await pool.end();
      process.exit(0);
    }

    console.log('📊 Encontrado:');
    if (cols.length > 0) console.log(`   ${cols.length} coluna(s) com collation diferente`);
    if (tables.length > 0) console.log(`   ${tables.length} tabela(s) com collation diferente\n`);

    if (cols.length > 0) {
      console.log('📋 Colunas a ajustar:');
      console.table(cols);
    }

    if (tables.length > 0) {
      console.log('\n📋 Tabelas a ajustar:');
      console.table(tables);
    }

    console.log('\n⚠️  AVISO: ALTER TABLE ... CONVERT TO CHARACTER SET reescreve a tabela.');
    console.log('   Em tabelas grandes, isso pode demorar e bloquear a tabela.');
    console.log('   Faça BACKUP antes de continuar!\n');

    const proceed = await question('Deseja continuar? (s/n) ');
    if (proceed.toLowerCase() !== 's') {
      console.log('Operação cancelada.');
      rl.close();
      await pool.end();
      process.exit(0);
    }

    // Get unique tables to convert
    const tablesToConvert = [...new Set(cols.map(c => c.TABLE_NAME))];
    
    console.log('\n' + '='.repeat(60));
    console.log('CONVERTENDO TABELAS');
    console.log('='.repeat(60) + '\n');

    let convertedCount = 0;
    for (const tableName of tablesToConvert) {
      console.log(`\n[${convertedCount + 1}/${tablesToConvert.length}] Convertendo tabela: ${tableName}`);
      
      const confirm = await question('  Converter? (s/n): ');
      if (confirm.toLowerCase() === 's') {
        try {
          await pool.query(
            `ALTER TABLE \`${tableName}\` CONVERT TO CHARACTER SET utf8mb4 COLLATE ${TARGET_COLLATION}`
          );
          console.log(`  ✓ Tabela ${tableName} convertida com sucesso`);
          convertedCount++;
        } catch (err) {
          console.error(`  ❌ Erro ao converter tabela ${tableName}:`, err.message);
        }
      } else {
        console.log('  ⊘ Pulado');
      }
    }

    // Also convert database default collation if needed
    console.log('\n' + '='.repeat(60));
    console.log('CONVERTENDO DATABASE DEFAULT');
    console.log('='.repeat(60) + '\n');

    const confirm = await question('Alterar collation padrão do database? (s/n) ');
    if (confirm.toLowerCase() === 's') {
      try {
        await pool.query(
          `ALTER DATABASE \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE ${TARGET_COLLATION}`
        );
        console.log(`✓ Database default collation alterado para ${TARGET_COLLATION}`);
      } catch (err) {
        console.error(`❌ Erro ao alterar database collation:`, err.message);
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('RESUMO');
    console.log('='.repeat(60));
    console.log(`✓ ${convertedCount} de ${tablesToConvert.length} tabela(s) convertida(s)\n`);

    if (convertedCount > 0) {
      console.log('✅ Tabelas foram convertidas com sucesso!');
      console.log('   Reinicie a API para que as mudanças tenham efeito.\n');
    } else {
      console.log('⊘ Nenhuma tabela foi convertida.\n');
    }

  } catch (err) {
    console.error('❌ Erro:', err.message || err);
  } finally {
    rl.close();
    try { await pool.end(); } catch (e) {}
    process.exit(0);
  }
})();
