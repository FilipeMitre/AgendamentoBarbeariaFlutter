const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); // Carrega as variáveis de ambiente

// Importar rotas
const authRoutes = require('./routes/authRoutes');
const carteiraRoutes = require('./routes/carteiraRoutes');
const agendamentoRoutes = require('./routes/agendamentoRoutes');
const avaliacaoRoutes = require('./routes/avaliacaoRoutes');
const barbeiroRoutes = require('./routes/barbeiroRoutes');
const produtoRoutes = require('./routes/produtoRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors()); // Permite requisições de diferentes origens
app.use(bodyParser.json()); // Para parsear JSON no corpo das requisições
app.use(bodyParser.urlencoded({ extended: true })); // Para parsear URL-encoded data

// Rotas da API
app.use('/api/auth', authRoutes);
app.use('/api/carteira', carteiraRoutes);
app.use('/api/agendamentos', agendamentoRoutes);
app.use('/api/avaliacoes', avaliacaoRoutes);
app.use('/api/barbeiro', barbeiroRoutes);
app.use('/api/produtos', produtoRoutes);
app.use('/api/admin', adminRoutes);

// Rota de teste
app.get('/', (req, res) => {
  res.send('API GIAT Barbershop está online!');
});

// Tratamento de erros (opcional, mas recomendado)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Algo deu errado!');
});

// Iniciar o servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`Ambiente: ${process.env.NODE_ENV}`);
});

// Importar e testar conexão com o banco de dados
require('./config/database');
