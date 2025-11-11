const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Hash de senha
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
};

// Comparar senha
const comparePassword = async (password, hashedPassword) => {
  return await bcrypt.compare(password, hashedPassword);
};

// Gerar token JWT
const generateToken = (userId, tipoUsuario) => {
  return jwt.sign(
    { id: userId, tipo: tipoUsuario },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

// Verificar token JWT
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    return null;
  }
};

// Formatar data para MySQL
const formatDateForMySQL = (date) => {
  return date.toISOString().slice(0, 19).replace('T', ' ');
};

// Calcular comissão
const calcularComissao = (valorServico) => {
  const taxaComissao = parseFloat(process.env.TAXA_COMISSAO) || 5;
  return (valorServico * taxaComissao) / 100;
};

// Calcular valor do barbeiro
const calcularValorBarbeiro = (valorServico, comissao) => {
  return valorServico - comissao;
};

// Validar CPF
const validarCPF = (cpf) => {
  cpf = cpf.replace(/[^\d]/g, '');

  if (cpf.length !== 11) return false;
  if (/^(\d)\1{10}$/.test(cpf)) return false;

  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(cpf.charAt(i)) * (10 - i);
  }
  let digit = 11 - (sum % 11);
  if (digit >= 10) digit = 0;
  if (digit !== parseInt(cpf.charAt(9))) return false;

  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += parseInt(cpf.charAt(i)) * (11 - i);
  }
  digit = 11 - (sum % 11);
  if (digit >= 10) digit = 0;
  if (digit !== parseInt(cpf.charAt(10))) return false;

  return true;
};

module.exports = {
  hashPassword,
  comparePassword,
  generateToken,
  verifyToken,
  formatDateForMySQL,
  calcularComissao,
  calcularValorBarbeiro,
  validarCPF
};
