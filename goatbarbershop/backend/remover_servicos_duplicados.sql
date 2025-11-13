-- ============================================
-- REMOVER SERVIÇOS DUPLICADOS
-- ============================================

-- Verificar serviços duplicados
SELECT nome, COUNT(*) as quantidade
FROM servicos
WHERE ativo = TRUE
GROUP BY nome
HAVING COUNT(*) > 1;

-- Remover os IDs duplicados (9-16)
-- Primeiro, remover as referências em outras tabelas
DELETE FROM barbeiro_servicos WHERE servico_id IN (9, 10, 11, 12, 13, 14, 15, 16);

-- Depois, remover os serviços duplicados
DELETE FROM servicos WHERE id IN (9, 10, 11, 12, 13, 14, 15, 16);

-- Verificar resultado
SELECT id, nome, preco_base, duracao_minutos
FROM servicos
WHERE ativo = TRUE
ORDER BY id;
