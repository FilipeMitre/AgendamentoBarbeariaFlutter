const db = require('../config/database');
const { hashPassword, comparePassword, generateToken, validarCPF } = require('../utils/helpers');

// Registro de usuário
exports.register = async (req, res) => {
  const connection = await db.getConnection();

  try {
    const { nome, cpf, email, senha, telefone, tipo_usuario } = req.body;

    // Validações
    if (!nome || !email || !senha) {
      return res.status(400).json({
        success: false,
        message: 'Nome, email e senha são obrigatórios'
      });
    }

    // Validar CPF se fornecido
    if (cpf && !validarCPF(cpf)) {
      return res.status(400).json({
        success: false,
        message: 'CPF inválido'
      });
    }

    // Verificar se email já existe
    const [existingUser] = await connection.query(
      'SELECT id FROM usuarios WHERE email = ?',
      [email]
    );

    if (existingUser.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email já cadastrado'
      });
    }

    // Verificar se CPF já existe
    if (cpf) {
      const [existingCPF] = await connection.query(
        'SELECT id FROM usuarios WHERE cpf = ?',
        [cpf.replace(/[^\d]/g, '')]
      );

      if (existingCPF.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'CPF já cadastrado'
        });
      }
    }

    await connection.beginTransaction();

    // Hash da senha
    const senhaHash = await hashPassword(senha);

    // Inserir usuário
    const [result] = await connection.query(
      `INSERT INTO usuarios (nome, cpf, email, telefone, senha_hash, tipo_usuario) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        nome,
        cpf ? cpf.replace(/[^\d]/g, '') : null,
        email,
        telefone || '',
        senhaHash,
        tipo_usuario || 'cliente'
      ]
    );

    const userId = result.insertId;

    // Verificar se já existe carteira para o usuário
    const [existingWallet] = await connection.query(
      'SELECT id FROM carteiras WHERE usuario_id = ?',
      [userId]
    );

    // Criar carteira apenas se não existir
    if (existingWallet.length === 0) {
      await connection.query(
        'INSERT INTO carteiras (usuario_id, saldo) VALUES (?, 0.00)',
        [userId]
      );
    }

    await connection.commit();

    // Buscar usuário criado
    const [user] = await connection.query(
      `SELECT id, nome, email, telefone, cpf, tipo_usuario, ativo, data_cadastro 
       FROM usuarios WHERE id = ?`,
      [userId]
    );

    // Gerar token
    const token = generateToken(userId, user[0].tipo_usuario);

    res.status(201).json({
      success: true,
      message: 'Usuário cadastrado com sucesso',
      user: user[0],
      token
    });

  } catch (error) {
    await connection.rollback();
    console.error('Erro no registro:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao cadastrar usuário',
      error: error.message
    });
  } finally {
    connection.release();
  }
};

// Login
exports.login = async (req, res) => {
  try {
    const { email, senha } = req.body;

    // Validações
    if (!email || !senha) {
      return res.status(400).json({
        success: false,
        message: 'Email e senha são obrigatórios'
      });
    }

    // Buscar usuário
    const [users] = await db.query(
      `SELECT id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo 
       FROM usuarios WHERE email = ?`,
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email ou senha incorretos'
      });
    }

    const user = users[0];

    // Verificar se usuário está ativo
    if (!user.ativo) {
      return res.status(403).json({
        success: false,
        message: 'Usuário inativo. Entre em contato com o administrador.'
      });
    }

    // Verificar senha
    const senhaValida = await comparePassword(senha, user.senha_hash);

    if (!senhaValida) {
      return res.status(401).json({
        success: false,
        message: 'Email ou senha incorretos'
      });
    }

    // Criar carteira se não existir (para barbeiros)
    if (user.tipo_usuario === 'barbeiro') {
      const [existingWallet] = await db.query(
        'SELECT id FROM carteiras WHERE usuario_id = ?',
        [user.id]
      );

      if (existingWallet.length === 0) {
        await db.query(
          'INSERT INTO carteiras (usuario_id, saldo) VALUES (?, 0.00)',
          [user.id]
        );
      }
    }

    // Remover senha do objeto
    delete user.senha_hash;

    // Gerar token
    const token = generateToken(user.id, user.tipo_usuario);

    res.json({
      success: true,
      message: 'Login realizado com sucesso',
      user,
      token
    });

  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao fazer login',
      error: error.message
    });
  }
};

// Verificar token
exports.verifyToken = async (req, res) => {
  try {
    const [users] = await db.query(
      `SELECT id, nome, email, telefone, cpf, tipo_usuario, ativo 
       FROM usuarios WHERE id = ?`,
      [req.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Usuário não encontrado'
      });
    }

    res.json({
      success: true,
      user: users[0]
    });

  } catch (error) {
    console.error('Erro ao verificar token:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao verificar token',
      error: error.message
    });
  }
};
