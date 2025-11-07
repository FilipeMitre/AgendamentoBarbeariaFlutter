-- Remover triggers existentes que podem estar causando débito duplo
DROP TRIGGER IF EXISTS trg_criar_taxa_agendamento;
DROP TRIGGER IF EXISTS trg_atualizar_saldo_apos_concluido;

-- Criar trigger correto para débito no momento da criação do agendamento
DELIMITER $$

CREATE TRIGGER trg_debitar_agendamento
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    
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
        INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
        VALUES (v_id_carteira, v_preco_servico, 'debito', NEW.id);
    END IF;
END$$

DELIMITER ;

-- Criar trigger para reembolso quando cancelar
DELIMITER $$

CREATE TRIGGER trg_reembolsar_cancelamento
AFTER UPDATE ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    
    -- Se mudou de confirmado para cancelado, reembolsar
    IF OLD.status = 'confirmado' AND NEW.status = 'cancelado' THEN
        SELECT preco_creditos INTO v_preco_servico
        FROM servicos
        WHERE id = NEW.id_servico;
        
        SELECT id INTO v_id_carteira
        FROM carteiras
        WHERE id_cliente = NEW.id_cliente;
        
        IF v_id_carteira IS NOT NULL THEN
            UPDATE carteiras
            SET saldo = saldo + v_preco_servico
            WHERE id = v_id_carteira;
            
            INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
            VALUES (v_id_carteira, v_preco_servico, 'credito', NEW.id);
        END IF;
    END IF;
END$$

DELIMITER ;