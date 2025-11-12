const express = require('express');
const router = express.Router();
const agendamentoController = require('../controllers/agendamentoController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/', authMiddleware, agendamentoController.criarAgendamento);
router.get('/:usuarioId/ativos', authMiddleware, agendamentoController.getAgendamentosAtivos);
router.get('/:usuarioId/historico', authMiddleware, agendamentoController.getHistoricoAgendamentos);
router.put('/:agendamentoId/cancelar', authMiddleware, agendamentoController.cancelarAgendamento);

// Rotas para horários em tempo real
router.get('/horarios-disponiveis', agendamentoController.getHorariosDisponiveis);
router.get('/dias-disponiveis', agendamentoController.getDiasDisponiveis);
router.get('/verificar-disponibilidade', agendamentoController.verificarDisponibilidade);

// Rota para buscar serviços ativos
router.get('/servicos', agendamentoController.getServicosAtivos);

// Endpoint de teste


module.exports = router;
