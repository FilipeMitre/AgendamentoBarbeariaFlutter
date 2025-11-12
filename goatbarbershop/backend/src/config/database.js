const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

// Testar conexão
pool.getConnection()
  .then(connection => {
    console.log('✅ Conectado ao banco de dados MySQL');
    connection.release();
  })
  .catch(err => {
    console.error('❌ Erro ao conectar ao banco de dados:', err.message);
  });

// Sobrescreve getConnection para garantir que a sessão use a collation desejada.
// O driver mysql2 não aceita a opção `collation` no pool (gera warning),
// então definimos explicitamente na sessão após obter a conexão.
const originalGetConnection = pool.getConnection.bind(pool);
pool.getConnection = async function () {
  const connection = await originalGetConnection();
  try {
    // Define charset e collation da sessão para evitar mistura de collations
    await connection.query("SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci'");
  } catch (err) {
    // Se falhar, libera a conexão e propaga o erro
    connection.release();
    throw err;
  }
  return connection;
};

// Também aplica a configuração nas conexões criadas pelo pool (cobre pool.query internamente)
try {
  if (typeof pool.on === 'function') {
    pool.on('connection', (connection) => {
      // Usa callback para não depender do wrapper promise
      connection.query("SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci'", (err) => {
        if (err) {
          console.error('Erro ao configurar collation na conexão do pool:', err.message);
        }
      });
    });
  }
} catch (e) {
  // Caso a API do pool não suporte 'on' nesta versão, ignoramos (já temos override de getConnection)
  console.warn('Aviso: não foi possível registrar handler de conexão do pool para definir collation.');
}

module.exports = pool;
