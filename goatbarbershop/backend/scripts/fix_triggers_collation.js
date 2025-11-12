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

async function getTriggersToFix() {
  const [triggers] = await pool.query(
    `SELECT TRIGGER_SCHEMA, TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
     FROM information_schema.TRIGGERS
     WHERE TRIGGER_SCHEMA = ? AND CHARACTER_SET_CLIENT = 'utf8mb4' AND COLLATION_CONNECTION LIKE '%0900%'
     ORDER BY TRIGGER_NAME`,
    [DB_NAME]
  );
  return triggers;
}

async function getProcsToFix() {
  const [procs] = await pool.query(
    `SELECT ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE
     FROM information_schema.ROUTINES
     WHERE ROUTINE_SCHEMA = ? AND CHARACTER_SET_CLIENT = 'utf8mb4' AND COLLATION_CONNECTION LIKE '%0900%'
     ORDER BY ROUTINE_NAME`,
    [DB_NAME]
  );
  return procs;
}

async function getTriggerDefinition(triggerName) {
  const [result] = await pool.query(
    `SHOW CREATE TRIGGER \`${DB_NAME}\`.\`${triggerName}\``
  );
  return result[0]['SQL Original Statement'];
}

async function getProcedureDefinition(procName) {
  const [result] = await pool.query(
    `SHOW CREATE PROCEDURE \`${DB_NAME}\`.\`${procName}\``
  );
  return result[0]['Create Procedure'];
}

async function dropAndRecreateTrigger(triggerName, newDefinition) {
  const [triggerInfo] = await pool.query(
    `SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE FROM information_schema.TRIGGERS
     WHERE TRIGGER_SCHEMA = ? AND TRIGGER_NAME = ?`,
    [DB_NAME, triggerName]
  );
  
  if (triggerInfo.length === 0) {
    console.log(`  ❌ Trigger ${triggerName} não encontrado`);
    return false;
  }

  const tableName = triggerInfo[0].EVENT_OBJECT_TABLE;
  
  try {
    // DROP trigger
    await pool.query(`DROP TRIGGER \`${DB_NAME}\`.\`${triggerName}\``);
    console.log(`  ✓ Trigger ${triggerName} removido`);

    // RECREATE com collation unicode
    const newSql = newDefinition.replace(
      /COLLATE utf8mb4_0900_ai_ci/gi,
      `COLLATE ${TARGET_COLLATION}`
    ).replace(
      /CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci/gi,
      `CHARACTER SET utf8mb4 COLLATE ${TARGET_COLLATION}`
    );

    await pool.query(newSql);
    console.log(`  ✓ Trigger ${triggerName} recriado com collation ${TARGET_COLLATION}`);
    return true;
  } catch (err) {
    console.error(`  ❌ Erro ao recriar trigger ${triggerName}:`, err.message);
    return false;
  }
}

async function dropAndRecreateProcedure(procName, newDefinition) {
  try {
    // DROP procedure
    await pool.query(`DROP PROCEDURE IF EXISTS \`${DB_NAME}\`.\`${procName}\``);
    console.log(`  ✓ Procedure ${procName} removida`);

    // RECREATE com collation unicode
    const newSql = newDefinition.replace(
      /COLLATE utf8mb4_0900_ai_ci/gi,
      `COLLATE ${TARGET_COLLATION}`
    ).replace(
      /CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci/gi,
      `CHARACTER SET utf8mb4 COLLATE ${TARGET_COLLATION}`
    );

    await pool.query(newSql);
    console.log(`  ✓ Procedure ${procName} recriada com collation ${TARGET_COLLATION}`);
    return true;
  } catch (err) {
    console.error(`  ❌ Erro ao recriar procedure ${procName}:`, err.message);
    return false;
  }
}

(async () => {
  try {
    console.log(`\n🔍 Inspecionando banco: ${DB_NAME}`);
    console.log(`   Target collation: ${TARGET_COLLATION}\n`);

    const triggers = await getTriggersToFix();
    const procs = await getProcsToFix();

    console.log(`📊 Encontrados:`);
    console.log(`   ${triggers.length} trigger(s) com collation 0900`);
    console.log(`   ${procs.length} procedure(s) com collation 0900\n`);

    if (triggers.length === 0 && procs.length === 0) {
      console.log('✅ Nenhum trigger ou procedure com collation 0900 encontrado.');
      rl.close();
      await pool.end();
      process.exit(0);
    }

    console.log('⚠️  AVISO: Este script irá DROP e RECREAR triggers/procedures.');
    console.log('   Faça BACKUP do seu banco antes de continuar!\n');

    const proceed = await question('Deseja continuar? (s/n) ');
    if (proceed.toLowerCase() !== 's') {
      console.log('Operação cancelada.');
      rl.close();
      await pool.end();
      process.exit(0);
    }

    console.log('\n' + '='.repeat(60));
    console.log('PROCESSANDO TRIGGERS');
    console.log('='.repeat(60) + '\n');

    let triggerCount = 0;
    for (const trigger of triggers) {
      console.log(`\n[${triggerCount + 1}/${triggers.length}] ${trigger.TRIGGER_NAME}`);
      console.log(`  Tabela: ${trigger.EVENT_OBJECT_TABLE}`);
      console.log(`  Evento: ${trigger.EVENT_MANIPULATION}`);

      const confirm = await question('  Recriar? (s/n): ');
      if (confirm.toLowerCase() === 's') {
        const definition = await getTriggerDefinition(trigger.TRIGGER_NAME);
        const success = await dropAndRecreateTrigger(trigger.TRIGGER_NAME, definition);
        if (success) triggerCount++;
      } else {
        console.log('  ⊘ Pulado');
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('PROCESSANDO PROCEDURES');
    console.log('='.repeat(60) + '\n');

    let procCount = 0;
    for (const proc of procs) {
      console.log(`\n[${procCount + 1}/${procs.length}] ${proc.ROUTINE_NAME}`);
      console.log(`  Tipo: ${proc.ROUTINE_TYPE}`);

      const confirm = await question('  Recriar? (s/n): ');
      if (confirm.toLowerCase() === 's') {
        const definition = await getProcedureDefinition(proc.ROUTINE_NAME);
        const success = await dropAndRecreateProcedure(proc.ROUTINE_NAME, definition);
        if (success) procCount++;
      } else {
        console.log('  ⊘ Pulado');
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('RESUMO');
    console.log('='.repeat(60));
    console.log(`✓ ${triggerCount} de ${triggers.length} trigger(s) recriado(s)`);
    console.log(`✓ ${procCount} de ${procs.length} procedure(s) recriada(s)\n`);

    if (triggerCount > 0 || procCount > 0) {
      console.log('✅ Triggers e procedures foram atualizados com sucesso!');
      console.log('   Reinicie a API para que as mudanças tenham efeito.\n');
    } else {
      console.log('⊘ Nenhum trigger ou procedure foi recriado.\n');
    }

  } catch (err) {
    console.error('❌ Erro:', err.message || err);
  } finally {
    rl.close();
    try { await pool.end(); } catch (e) {}
    process.exit(0);
  }
})();
