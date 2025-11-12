-- =================================================================================
-- SCRIPT PARA CORREÇÃO DE COLLATION DO BANCO DE DADOS
-- =================================================================================
-- OBJETIVO:
-- Padronizar o character set e a collation de todas as tabelas para evitar o erro
-- "Illegal mix of collations".
--
-- INSTRUÇÕES:
-- 1. Conecte-se ao seu banco de dados MySQL.
-- 2. Execute o conteúdo deste script.
-- =================================================================================

-- Altera a collation padrão do banco de dados.
ALTER DATABASE barbearia_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Altera a collation para cada tabela individualmente.
ALTER TABLE usuarios CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE carteiras CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE servicos CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE barbeiro_servicos CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE horarios_funcionamento CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE disponibilidade_barbeiro CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE agendamentos CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE transacoes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE avaliacoes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE notificacoes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE configuracoes_sistema CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE categorias_produto CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE produtos CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vendas CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE itens_venda CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE recomendacoes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- =================================================================================
-- FIM DO SCRIPT
-- =================================================================================