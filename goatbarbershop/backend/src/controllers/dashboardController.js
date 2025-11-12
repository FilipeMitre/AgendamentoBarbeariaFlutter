const db = require('../config/database');

// Obter dados para o dashboard do administrador
exports.getAdminDashboard = async (req, res) => {
    try {
        // Total de usuários
        const [totalUsuarios] = await db.query("SELECT COUNT(*) as total FROM usuarios");
        // Total de barbeiros
        const [totalBarbeiros] = await db.query("SELECT COUNT(*) as total FROM usuarios WHERE tipo_usuario = 'barbeiro'");
        // Total de agendamentos
        const [totalAgendamentos] = await db.query("SELECT COUNT(*) as total FROM agendamentos");
        // Receita total (soma de todos os serviços concluídos)
        const [receitaTotal] = await db.query("SELECT SUM(valor_servico) as total FROM agendamentos WHERE status = 'concluido'");
        // Total de produtos
        const [totalProdutos] = await db.query("SELECT COUNT(*) as total FROM produtos");

        res.json({
            success: true,
            data: {
                totalUsuarios: totalUsuarios[0].total,
                totalBarbeiros: totalBarbeiros[0].total,
                totalAgendamentos: totalAgendamentos[0].total,
                receitaTotal: parseFloat(receitaTotal[0].total) || 0,
                totalProdutos: totalProdutos[0].total,
            }
        });
    } catch (error) {
        console.error('Erro ao obter dados do dashboard do administrador:', error);
        res.status(500).json({
            success: false,
            message: 'Erro ao obter dados do dashboard',
            error: error.message
        });
    }
};

// Obter dados para o dashboard do barbeiro
exports.getBarberDashboard = async (req, res) => {
    try {
        const barbeiroId = req.userId;

        // Agendamentos do dia
        const [agendamentosHoje] = await db.query(
            `SELECT COUNT(*) as total 
             FROM agendamentos 
             WHERE barbeiro_id = ? AND DATE(data_agendamento) = CURDATE() AND status = 'confirmado'`,
            [barbeiroId]
        );

        // Próximo agendamento
        const [proximoAgendamento] = await db.query(
            `SELECT * 
             FROM agendamentos 
             WHERE barbeiro_id = ? AND status = 'confirmado' AND CONCAT(data_agendamento, ' ', horario) >= NOW() 
             ORDER BY data_agendamento, horario 
             LIMIT 1`,
            [barbeiroId]
        );

        // Total a receber (soma dos valores de barbeiro para agendamentos concluídos)
        const [totalReceber] = await db.query(
            `SELECT SUM(valor_barbeiro) as total 
             FROM agendamentos 
             WHERE barbeiro_id = ? AND status = 'concluido'`,
            [barbeiroId]
        );

        res.json({
            success: true,
            data: {
                agendamentosHoje: agendamentosHoje[0].total,
                proximoAgendamento: proximoAgendamento.length > 0 ? proximoAgendamento[0] : null,
                totalReceber: parseFloat(totalReceber[0].total) || 0,
            }
        });
    } catch (error) {
        console.error('Erro ao obter dados do dashboard do barbeiro:', error);
        res.status(500).json({
            success: false,
            message: 'Erro ao obter dados do dashboard',
            error: error.message
        });
    }
};