const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// Criar/conectar ao banco SQLite
const dbPath = path.join(__dirname, 'database.db');
const db = new sqlite3.Database(dbPath);

// Criar tabelas se não existirem
db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    cpf TEXT,
    senha TEXT,
    papel TEXT DEFAULT 'cliente',
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS carteiras (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente INTEGER NOT NULL,
    saldo DECIMAL(10,2) DEFAULT 0.00,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id)
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS transacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_carteira INTEGER NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    tipo TEXT NOT NULL,
    id_agendamento INTEGER,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carteira) REFERENCES carteiras(id)
  )`);
});

// Endpoint para executar queries
app.post('/api/query', (req, res) => {
  const { sql, params = [] } = req.body;
  
  console.log('Query recebida:', sql);
  console.log('Parâmetros:', params);

  // Verificar se é SELECT ou INSERT/UPDATE/DELETE
  if (sql.trim().toUpperCase().startsWith('SELECT')) {
    db.all(sql, params, (err, rows) => {
      if (err) {
        console.error('Erro na query SELECT:', err);
        res.status(500).json({ error: err.message });
      } else {
        console.log('Resultado SELECT:', rows);
        res.json({ results: rows });
      }
    });
  } else {
    db.run(sql, params, function(err) {
      if (err) {
        console.error('Erro na query:', err);
        res.status(500).json({ error: err.message });
      } else {
        console.log('Query executada com sucesso. LastID:', this.lastID, 'Changes:', this.changes);
        res.json({ 
          results: [{ 
            lastID: this.lastID, 
            changes: this.changes,
            success: true 
          }] 
        });
      }
    });
  }
});

// Endpoint de teste
app.get('/api/test', (req, res) => {
  res.json({ message: 'API funcionando!', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
  console.log('Acesse http://localhost:3001/api/test para testar');
  console.log('Banco de dados SQLite criado em:', dbPath);
});