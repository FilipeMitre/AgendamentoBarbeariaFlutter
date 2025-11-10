-- Correção final do trigger para evitar débito duplo
-- Remove o trigger problemático e cria um novo mais simples

-- Remover trigger existente
DROP TRIGGER IF EXISTS trg_debitar_agendamento_condicional;

-- Criar trigger que NUNCA executa quando há controle da aplicação
DELIMITER $$

CREATE TRIGGER trg_debitar_agendamento_simples
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    DECLARE v_disable_trigger INT DEFAULT 0;
    
    -- Verificar se o trigger deve ser desabilitado
    SELECT COALESCE(@disable_trigger, 0) INTO v_disable_trigger;
    
    -- Só executar se NÃO estiver desabilitado
    IF v_disable_trigger = 0 THEN
        -- Buscar preço do serviço
        SELECT preco_creditos INTO v_preco_servico
        FROM servicos
        WHERE id = NEW.id_servico;
        
        -- Buscar ID da carteira
        SELECT id INTO v_id_carteira
        FROM carteiras
        WHERE id_cliente = NEW.id_cliente;
        
        -- Debitar da carteira
        IF v_id_carteira IS NOT NULL THEN
            UPDATE carteiras
            SET saldo = saldo - v_preco_servico
            WHERE id = v_id_carteira;
            
            -- Registrar transação
            INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento, descricao)
            VALUES (v_id_carteira, v_preco_servico, 'debito', NEW.id, 'Pagamento automático de serviço');
        END IF;
    END IF;
END$$

DELIMITER ;

-- Comentário: 
-- Agora o trigger verifica corretamente se @disable_trigger está definido
-- Se estiver definido como 1, o trigger não executa
-- Se não estiver definido ou for 0, o trigger executa normalmente