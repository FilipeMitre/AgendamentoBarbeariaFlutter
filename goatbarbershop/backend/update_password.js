const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function updatePassword() {
  try {
    // Conectar ao banco
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    // Gerar hash da senha "123456"
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('123456', salt);
    
    console.log('Nova senha hash:', hashedPassword);

    // Atualizar todos os barbeiros
    const [result] = await connection.execute(
      'UPDATE usuarios SET senha_hash = ? WHERE tipo_usuario = "barbeiro"',
      [hashedPassword]
    );

    console.log(`${result.affectedRows} barbeiros atualizados com sucesso!`);
    console.log('Agora você pode fazer login com:');
    console.log('Email: haku@goatbarber.com');
    console.log('Senha: 123456');

    await connection.end();
  } catch (error) {
    console.error('Erro:', error);
  }
}

updatePassword();