const express = require('express');
const router = express.Router();
const avaliacaoController = require('../controllers/avaliacaoController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/', authMiddleware, avaliacaoController.criarAvaliacao);
router.get('/barbeiro/:barbeiroId', authMiddleware, avaliacaoController.getAvaliacoesBarbeiro);

module.exports = router;
