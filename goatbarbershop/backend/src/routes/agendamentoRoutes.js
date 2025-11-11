const express = require('express');
const router = express.Router();
const agendamentoController = require('../controllers/agendamentoController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/', authMiddleware, agendamentoController.criarAgendamento);
router.get('/:usuarioId/ativos', authMiddleware, agendamentoController.getAgendamentosAtivos);
router.get('/:usuarioId/historico', authMiddleware, agendamentoController.getHistoricoAgendamentos);
router.put('/:agendamentoId/cancelar', authMiddleware, agendamentoController.cancelarAgendamento);

module.exports = router;
