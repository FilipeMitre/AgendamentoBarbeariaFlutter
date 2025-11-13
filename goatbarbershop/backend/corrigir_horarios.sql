-- ============================================
-- CORRIGIR HORÁRIOS DE FUNCIONAMENTO
-- De segunda a sexta: 08:00 a 17:30
-- Sábado: 09:00 a 16:30
-- ============================================

UPDATE horarios_funcionamento SET 
    horario_abertura = '08:00:00',
    horario_fechamento = '17:30:00'
WHERE dia_semana IN ('segunda', 'terca', 'quarta', 'quinta', 'sexta');

UPDATE horarios_funcionamento SET 
    horario_abertura = '09:00:00',
    horario_fechamento = '16:30:00'
WHERE dia_semana = 'sabado';

-- Verificar resultados
SELECT dia_semana, horario_abertura, horario_fechamento FROM horarios_funcionamento ORDER BY 
  CASE 
    WHEN dia_semana = 'domingo' THEN 0
    WHEN dia_semana = 'segunda' THEN 1
    WHEN dia_semana = 'terca' THEN 2
    WHEN dia_semana = 'quarta' THEN 3
    WHEN dia_semana = 'quinta' THEN 4
    WHEN dia_semana = 'sexta' THEN 5
    WHEN dia_semana = 'sabado' THEN 6
  END;
