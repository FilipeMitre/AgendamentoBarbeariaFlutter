const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middlewares/authMiddleware');
const adminMiddleware = require('../middlewares/adminMiddleware');

// Rotas de Estatísticas
router.get('/estatisticas', authMiddleware, adminMiddleware, adminController.getEstatisticasAdmin);

// Rotas de Usuários
router.get('/usuarios', authMiddleware, adminMiddleware, adminController.getUsuarios);
router.put('/usuarios/:id', authMiddleware, adminMiddleware, adminController.atualizarUsuario);

// Rotas de Serviços
router.get('/servicos', authMiddleware, adminMiddleware, adminController.getServicos);
router.post('/servicos', authMiddleware, adminMiddleware, adminController.adicionarServico);
router.put('/servicos/:id', authMiddleware, adminMiddleware, adminController.atualizarServico);

// Rotas de Produtos
router.get('/produtos', authMiddleware, adminMiddleware, adminController.getProdutosAdmin);
router.post('/produtos', authMiddleware, adminMiddleware, adminController.adicionarProduto);
router.put('/produtos/:id', authMiddleware, adminMiddleware, adminController.atualizarProduto);

// Rotas de Categorias de Produto
router.get('/categorias-produto', authMiddleware, adminMiddleware, adminController.getCategoriasProduto);
router.post('/categorias-produto', authMiddleware, adminMiddleware, adminController.adicionarCategoriaProduto);
router.put('/categorias-produto/:id', authMiddleware, adminMiddleware, adminController.atualizarCategoriaProduto);

module.exports = router;
