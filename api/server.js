const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// Configuração do MySQL
const dbConfig = {
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'Abivis54!',
  database: 'app_barbearia',
  timezone: '-03:00',
  dateStrings: true  // Retorna datas como strings, não como objetos Date
};

// Função para conectar ao MySQL
async function connectDB() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    console.log('Conectado ao MySQL: app_barbearia');
    return connection;
  } catch (error) {
    console.error('Erro ao conectar ao MySQL:', error);
    throw error;
  }
}

// Endpoint para executar queries
app.post('/api/query', async (req, res) => {
  const { sql, params = [] } = req.body;
  
  console.log('Query recebida:', sql);
  console.log('Parâmetros:', params);

  let connection;
  try {
    connection = await connectDB();
    
    // Verificar se é SELECT ou INSERT/UPDATE/DELETE
    if (sql.trim().toUpperCase().startsWith('SELECT')) {
      const [rows] = await connection.execute(sql, params);
      console.log('Resultado SELECT:', rows);
      res.json({ results: rows });
    } else {
      const [result] = await connection.execute(sql, params);
      console.log('Query executada com sucesso. InsertId:', result.insertId, 'AffectedRows:', result.affectedRows);
      res.json({ 
        results: [{ 
          insertId: result.insertId, 
          affectedRows: result.affectedRows,
          success: true 
        }] 
      });
    }
  } catch (error) {
    console.error('Erro na query MySQL:', error);
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) {
      await connection.end();
    }
  }
});

// Endpoint de teste
app.get('/api/test', async (req, res) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute('SELECT COUNT(*) as total FROM usuarios');
    res.json({ 
      message: 'API MySQL funcionando!', 
      timestamp: new Date().toISOString(),
      usuarios: rows[0].total
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Erro na conexão MySQL', 
      error: error.message 
    });
  } finally {
    if (connection) {
      await connection.end();
    }
  }
});

// Endpoint para listar usuários (debug)
app.get('/api/users', async (req, res) => {
  let connection;
  try {
    connection = await connectDB();
    const [rows] = await connection.execute('SELECT id, nome, email, criado_em FROM usuarios ORDER BY id DESC LIMIT 10');
    res.json({ users: rows });
  } catch (error) {
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) {
      await connection.end();
    }
  }
});

app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
  console.log('Acesse http://localhost:3001/api/test para testar');
  console.log('Usando MySQL: app_barbearia');
});