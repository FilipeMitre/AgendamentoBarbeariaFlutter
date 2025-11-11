const express = require('express');
const router = express.Router();
const carteiraController = require('../controllers/carteiraController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/:usuarioId/saldo', authMiddleware, carteiraController.getSaldo);
router.post('/:usuarioId/recarregar', authMiddleware, carteiraController.recarregar);
router.get('/:usuarioId/transacoes', authMiddleware, carteiraController.getTransacoes);

module.exports = router;
