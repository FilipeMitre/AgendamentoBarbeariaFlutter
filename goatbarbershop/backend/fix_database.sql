-- Script para corrigir problemas no banco de dados

-- 1. Verificar se existem carteiras duplicadas
SELECT usuario_id, COUNT(*) as total 
FROM carteiras 
GROUP BY usuario_id 
HAVING COUNT(*) > 1;

-- 2. Desabilitar modo seguro temporariamente
SET SQL_SAFE_UPDATES = 0;

-- 3. Remover carteiras duplicadas (manter apenas a primeira)
DELETE c1 FROM carteiras c1
INNER JOIN carteiras c2 
WHERE c1.id > c2.id AND c1.usuario_id = c2.usuario_id;

-- 4. Reabilitar modo seguro
SET SQL_SAFE_UPDATES = 1;

-- 5. Verificar se a constraint UNIQUE existe na tabela carteiras
SHOW INDEX FROM carteiras WHERE Key_name != 'PRIMARY';

-- 6. Adicionar constraint UNIQUE se não existir
ALTER TABLE carteiras 
ADD CONSTRAINT uk_carteiras_usuario_id UNIQUE (usuario_id);

-- 7. Verificar usuários sem carteira
SELECT u.id, u.nome, u.email 
FROM usuarios u 
LEFT JOIN carteiras c ON u.id = c.usuario_id 
WHERE c.usuario_id IS NULL;

-- 8. Criar carteiras para usuários que não possuem
INSERT IGNORE INTO carteiras (usuario_id, saldo)
SELECT id, 0.00 
FROM usuarios u 
WHERE NOT EXISTS (
    SELECT 1 FROM carteiras c WHERE c.usuario_id = u.id
);

-- 9. Verificar estrutura final
SELECT 
    u.id as usuario_id,
    u.nome,
    u.email,
    c.id as carteira_id,
    c.saldo
FROM usuarios u
LEFT JOIN carteiras c ON u.id = c.usuario_id
ORDER BY u.id;