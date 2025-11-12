const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const adminMiddleware = require('../middlewares/adminMiddleware');
const dashboardController = require('../controllers/dashboardController');

// Rota para o dashboard do administrador
router.get('/admin', authMiddleware, adminMiddleware, dashboardController.getAdminDashboard);

// Rota para o dashboard do barbeiro
router.get('/barber', authMiddleware, dashboardController.getBarberDashboard);

module.exports = router;