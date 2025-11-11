const express = require('express');
const router = express.Router();
const barbeiroController = require('../controllers/barbeiroController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/:barbeiroId/agendamentos', authMiddleware, barbeiroController.getAgendamentosDia);
router.put('/:agendamentoId/concluir', authMiddleware, barbeiroController.concluirAgendamento);
router.get('/:barbeiroId/estatisticas', authMiddleware, barbeiroController.getEstatisticas);

module.exports = router;
