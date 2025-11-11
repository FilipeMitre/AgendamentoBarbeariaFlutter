const express = require('express');
const router = express.Router();
const produtoController = require('../controllers/produtoController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/', produtoController.getProdutos); // Não precisa de auth para ver produtos
router.get('/bebidas', produtoController.getBebidas); // Não precisa de auth para ver bebidas
router.get('/:id', produtoController.getProdutoById); // Não precisa de auth para ver produto por ID

module.exports = router;
