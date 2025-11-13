-- Inserir agendamentos de teste para hoje
INSERT INTO agendamentos (cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valor_servico, status, data_criacao) VALUES
(4, 1, 1, CURDATE(), '10:00', 35.00, 'agendado', NOW()),
(4, 1, 2, CURDATE(), '14:00', 25.00, 'agendado', NOW()),
(4, 2, 3, CURDATE(), '16:00', 50.00, 'agendado', NOW());

-- Verificar se foram inseridos
SELECT * FROM agendamentos WHERE data_agendamento = CURDATE();