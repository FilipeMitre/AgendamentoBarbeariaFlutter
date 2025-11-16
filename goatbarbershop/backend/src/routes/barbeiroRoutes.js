const express = require('express');
const router = express.Router();
const barbeiroController = require('../controllers/barbeiroController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/:barbeiroId/inicializar', authMiddleware, barbeiroController.inicializarDados);
router.get('/:barbeiroId/agendamentos/todos', authMiddleware, barbeiroController.getTodosAgendamentos);
router.get('/:barbeiroId/agendamentos', authMiddleware, barbeiroController.getAgendamentosDia);
router.put('/agendamentos/:agendamentoId/concluir', authMiddleware, barbeiroController.concluirAgendamento);
router.put('/agendamentos/:agendamentoId/cancelar', authMiddleware, barbeiroController.cancelarAgendamento);
router.get('/:barbeiroId/estatisticas', authMiddleware, barbeiroController.getEstatisticas);

// Rotas para gerenciar horários de trabalho
router.get('/:barbeiroId/horarios', authMiddleware, barbeiroController.getHorariosTrabalho);
router.put('/:barbeiroId/horarios', authMiddleware, barbeiroController.atualizarHorariosTrabalho);
router.put('/:barbeiroId/horarios/:diaSemana', authMiddleware, barbeiroController.atualizarHorarioDia);

module.exports = router;
