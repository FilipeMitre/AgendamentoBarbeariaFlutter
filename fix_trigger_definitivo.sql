-- SOLUÇÃO DEFINITIVA: Remover completamente o trigger problemático
-- O controle de débito será feito 100% pela aplicação

-- Remover TODOS os triggers de débito
DROP TRIGGER IF EXISTS trg_debitar_agendamento_simples;
DROP TRIGGER IF EXISTS trg_debitar_agendamento_condicional;
DROP TRIGGER IF EXISTS trg_debitar_agendamento;

-- Manter apenas o trigger de reembolso para cancelamentos
-- (este não causa problemas pois só executa em UPDATE, não INSERT)

-- Comentário:
-- Agora o sistema funcionará assim:
-- 1. Aplicação debita o valor total (serviço + produtos + bebidas)
-- 2. Aplicação cria o agendamento SEM trigger de débito
-- 3. Resultado: débito único e correto

-- Para testar:
-- Saldo inicial: R$ 100,00
-- Serviço R$ 25,00 → Saldo final: R$ 75,00 (correto)