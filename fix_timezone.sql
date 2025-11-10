-- CORREÇÃO DE FUSO HORÁRIO
-- Problema: BD salva 12:00 mas mostra 15:00 (diferença de 3h = UTC vs UTC-3)

-- 1. Verificar dados atuais
SELECT 
    id,
    data_hora_agendamento,
    DATE(data_hora_agendamento) as data_local,
    TIME(data_hora_agendamento) as hora_local,
    status
FROM agendamentos 
ORDER BY data_hora_agendamento DESC;

-- 2. Corrigir agendamentos existentes (subtrair 3 horas para compensar)
UPDATE agendamentos 
SET data_hora_agendamento = DATE_SUB(data_hora_agendamento, INTERVAL 3 HOUR)
WHERE data_hora_agendamento > NOW();

-- 3. Verificar se a correção funcionou
SELECT 
    id,
    data_hora_agendamento,
    DATE(data_hora_agendamento) as data_corrigida,
    TIME(data_hora_agendamento) as hora_corrigida,
    status
FROM agendamentos 
ORDER BY data_hora_agendamento DESC;