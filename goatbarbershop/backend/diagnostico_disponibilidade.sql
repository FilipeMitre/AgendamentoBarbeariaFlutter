-- ============================================
-- DIAGNÓSTICO: Verificar Disponibilidade
-- ============================================

-- 1. Verificar horários_funcionamento
SELECT 'horarios_funcionamento' as tabela, COUNT(*) as total
FROM horarios_funcionamento
WHERE ativo = TRUE;

-- 2. Verificar disponibilidade_barbeiro para barbeiro 1
SELECT 'disponibilidade_barbeiro_barbeiro1' as info, COUNT(*) as total
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND ativo = TRUE;

-- 3. Verificar disponibilidade de segunda para barbeiro 1
SELECT 'segunda-feira_barbeiro1' as info, COUNT(*) as total
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND dia_semana = 'segunda' AND ativo = TRUE;

-- 4. Listar todos os horários de segunda para barbeiro 1
SELECT horario, CAST(horario AS CHAR) as horario_str, LENGTH(horario) as tamanho
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND dia_semana = 'segunda' AND ativo = TRUE
ORDER BY horario
LIMIT 10;

-- 5. Verificar tipos de dados
SELECT COLUMN_NAME, COLUMN_TYPE, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'disponibilidade_barbeiro' AND TABLE_SCHEMA = 'barbearia_app'
AND COLUMN_NAME IN ('horario', 'dia_semana');

-- 6. Contar horários por dia para barbeiro 1
SELECT dia_semana, COUNT(*) as total_horarios
FROM disponibilidade_barbeiro
WHERE barbeiro_id = 1 AND ativo = TRUE
GROUP BY dia_semana
ORDER BY FIELD(dia_semana, 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo');
