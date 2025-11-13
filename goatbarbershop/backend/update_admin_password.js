const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function updateAdminPassword() {
  try {
    // Conectar ao banco
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    // Verificar se admin existe
    const [adminCheck] = await connection.execute(
      'SELECT id, email FROM usuarios WHERE email = ?',
      ['admin@goatbarber.com']
    );

    if (adminCheck.length === 0) {
      console.log('Admin não encontrado. Criando...');
      
      // Gerar hash da senha "admin123"
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('admin123', salt);
      
      // Criar admin
      const [result] = await connection.execute(
        'INSERT INTO usuarios (nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES (?, ?, ?, ?, ?, ?, ?)',
        ['Admin GoatBarber', 'admin@goatbarber.com', '(71) 99999-9999', null, hashedPassword, 'admin', true]
      );
      
      console.log('Admin criado com ID:', result.insertId);
    } else {
      console.log('Admin encontrado. Atualizando senha...');
      
      // Gerar hash da senha "admin123"
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('admin123', salt);
      
      // Atualizar senha
      await connection.execute(
        'UPDATE usuarios SET senha_hash = ? WHERE email = ?',
        [hashedPassword, 'admin@goatbarber.com']
      );
      
      console.log('Senha do admin atualizada!');
    }

    console.log('Login do admin:');
    console.log('Email: admin@goatbarber.com');
    console.log('Senha: admin123');

    await connection.end();
  } catch (error) {
    console.error('Erro:', error);
  }
}

updateAdminPassword();