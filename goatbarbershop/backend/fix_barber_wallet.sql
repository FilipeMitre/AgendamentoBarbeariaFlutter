-- Verificar se barbeiro tem carteira
SELECT * FROM carteiras WHERE usuario_id = 1;

-- Se não existir, criar carteira para o barbeiro
INSERT IGNORE INTO carteiras (usuario_id, saldo) VALUES (1, 0.00);

-- Marcar um agendamento como concluído para gerar saldo
UPDATE agendamentos 
SET status = 'concluido', data_conclusao = NOW() 
WHERE barbeiro_id = 1 AND status = 'confirmado' 
LIMIT 1;