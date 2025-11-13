-- Criar agendamento para hoje para testar o dashboard
INSERT INTO agendamentos (
    cliente_id, 
    barbeiro_id, 
    servico_id, 
    data_agendamento, 
    horario, 
    valor_servico, 
    valor_comissao, 
    valor_barbeiro, 
    status
) VALUES (
    9004, -- cliente daniel
    1,    -- barbeiro 1
    1,    -- serviço Corte Masculino
    CURDATE(), -- hoje
    '14:00:00',
    35.00,
    1.75,
    33.25,
    'confirmado'
);