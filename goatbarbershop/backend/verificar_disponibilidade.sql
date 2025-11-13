-- Verificar disponibilidade do barbeiro 1 para segunda-feira
SELECT horario, COUNT(*) as total
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND dia_semana = 'segunda'
GROUP BY horario
ORDER BY horario;

-- Verificar todos os horários para segunda
SELECT COUNT(*) as total_horarios
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND dia_semana = 'segunda';

-- Listar todos os horários de segunda para barbeiro 1
SELECT barbeiro_id, dia_semana, horario, ativo
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND dia_semana = 'segunda'
ORDER BY horario;
