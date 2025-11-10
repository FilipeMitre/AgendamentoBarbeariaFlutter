-- Corrigir trigger para evitar débito duplo
-- Este arquivo corrige o problema onde produtos/bebidas não eram debitados da carteira

-- Remover trigger existente que só debita o serviço
DROP TRIGGER IF EXISTS trg_debitar_agendamento;

-- Criar trigger condicional que só debita se não for controlado pela aplicação
DELIMITER $$

CREATE TRIGGER trg_debitar_agendamento_condicional
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    
    -- Só executar se não for controlado pela aplicação
    IF @disable_trigger IS NULL THEN
        -- Buscar preço do serviço
        SELECT preco_creditos INTO v_preco_servico
        FROM servicos
        WHERE id = NEW.id_servico;
        
        -- Buscar ID da carteira
        SELECT id INTO v_id_carteira
        FROM carteiras
        WHERE id_cliente = NEW.id_cliente;
        
        -- Debitar da carteira (apenas o serviço)
        IF v_id_carteira IS NOT NULL THEN
            UPDATE carteiras
            SET saldo = saldo - v_preco_servico
            WHERE id = v_id_carteira;
            
            -- Registrar transação
            INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento, descricao)
            VALUES (v_id_carteira, v_preco_servico, 'debito', NEW.id, 'Pagamento de serviço');
        END IF;
    END IF;
END$$

DELIMITER ;

-- Criar tabela para registrar produtos/bebidas do agendamento (se não existir)
CREATE TABLE IF NOT EXISTS agendamento_produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_agendamento INT NOT NULL,
    nome_produto VARCHAR(255) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade INT DEFAULT 1,
    tipo ENUM('produto', 'bebida') NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id) ON DELETE CASCADE
);

-- Trigger para reembolso quando cancelar (mantém o mesmo)
DROP TRIGGER IF EXISTS trg_reembolsar_cancelamento;

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
            
            INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento, descricao)
            VALUES (v_id_carteira, v_preco_servico, 'credito', NEW.id, 'Reembolso por cancelamento');
        END IF;
    END IF;
END$$

DELIMITER ;

-- Comentário explicativo
-- PROBLEMA IDENTIFICADO:
-- O trigger anterior só debitava o valor do serviço (R$ 50,00)
-- Produtos e bebidas (R$ 4,59) não eram debitados
-- Resultado: Saldo incorreto (R$ 55,00 em vez de R$ 50,41)
-- 
-- SOLUÇÃO:
-- 1. Aplicação debita o valor total ANTES de criar o agendamento
-- 2. Trigger condicional evita débito duplo
-- 3. Sistema de reembolso em caso de erro