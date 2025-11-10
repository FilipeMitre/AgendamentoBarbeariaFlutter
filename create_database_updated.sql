-- ============================================
-- BANCO DE DADOS - APP BARBEARIA
-- Sistema completo com taxas de agendamento e produtos extras
-- VERSÃO CORRIGIDA - Fix do problema de débito duplo
-- ============================================

CREATE DATABASE IF NOT EXISTS app_barbearia;
USE app_barbearia;

-- ============================================
-- TABELAS PRINCIPAIS
-- ============================================

CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,  -- Formato: 000.000.000-00
    senha VARCHAR(255) NOT NULL,
    papel ENUM('cliente', 'barbeiro') NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS perfis_barbeiros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    bio TEXT,
    url_foto VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS servicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_barbeiro INT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    duracao_minutos INT NOT NULL,
    preco_creditos DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS horarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_barbeiro INT NOT NULL,
    dia_da_semana VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS bloqueios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_barbeiro INT NOT NULL,
    inicio_bloqueio DATETIME NOT NULL,
    fim_bloqueio DATETIME NOT NULL,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS agendamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_barbeiro INT NOT NULL,
    id_servico INT NOT NULL,
    data_hora_agendamento DATETIME NOT NULL,
    status ENUM('confirmado', 'cancelado', 'concluido') NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES servicos(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS carteiras (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS transacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_carteira INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    tipo ENUM('credito', 'debito') NOT NULL,
    descricao VARCHAR(255),
    id_agendamento INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carteira) REFERENCES carteiras(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS avaliacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_barbeiro INT NOT NULL,
    id_agendamento INT UNIQUE NOT NULL,
    nota INT NOT NULL,
    comentario TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (nota >= 1 AND nota <= 5)
);

CREATE TABLE IF NOT EXISTS notificacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    mensagem TEXT NOT NULL,
    tipo ENUM('agendamento_confirmado', 'cancelamento', 'nova_avaliacao') NOT NULL,
    lida BOOLEAN DEFAULT FALSE,
    criada_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================
-- NOVAS TABELAS - PRODUTOS E TAXAS
-- ============================================

CREATE TABLE IF NOT EXISTS produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    categoria ENUM('bebida', 'pomada', 'cera', 'shampoo', 'acessorio', 'outros') NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendas_produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_barbeiro INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    preco_total DECIMAL(10, 2) NOT NULL,
    id_agendamento INT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS taxas_agendamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_agendamento INT UNIQUE NOT NULL,
    valor_servico DECIMAL(10, 2) NOT NULL,
    taxa_garantia DECIMAL(10, 2) NOT NULL,
    taxa_paga BOOLEAN DEFAULT FALSE,
    data_pagamento_taxa TIMESTAMP NULL,
    reembolsada BOOLEAN DEFAULT FALSE,
    data_reembolso TIMESTAMP NULL,
    criada_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela para registrar produtos/bebidas do agendamento
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

-- ============================================
-- INSERÇÃO DE DADOS
-- ============================================

INSERT INTO usuarios (nome, email, cpf, senha, papel) VALUES
('João Barbeiro', 'joao.barbeiro@email.com', '123.456.789-01', 'senha123', 'barbeiro'),
('Maria Estilista', 'maria.estilista@email.com', '234.567.890-12', 'senha456', 'barbeiro'),
('Pedro Cliente', 'pedro.cliente@email.com', '345.678.901-23', 'senha789', 'cliente'),
('Ana Cliente', 'ana.cliente@email.com', '456.789.012-34', 'senhaabc', 'cliente');

INSERT INTO perfis_barbeiros (id_usuario, bio, url_foto) VALUES
(1, 'Especialista em cortes clássicos e barbas modeladas. 10 anos de experiência.', 'https://exemplo.com/foto_joao.jpg'),
(2, 'Artista do cabelo feminino e masculino, com foco em novas tendências.', 'https://exemplo.com/foto_maria.jpg');

INSERT INTO servicos (id_barbeiro, nome, duracao_minutos, preco_creditos) VALUES
(1, 'Corte Clássico', 45, 30.00),
(1, 'Barba Completa', 30, 25.00),
(1, 'Corte + Barba', 75, 50.00),
(2, 'Corte Moderno', 50, 40.00),
(2, 'Coloração', 120, 150.00),
(2, 'Design de Sobrancelha', 20, 20.00);

INSERT INTO horarios (id_barbeiro, dia_da_semana, hora_inicio, hora_fim) VALUES
-- João Barbeiro (id=1)
(1, 'Segunda-feira', '09:00:00', '18:00:00'),
(1, 'Terça-feira', '09:00:00', '18:00:00'),
(1, 'Quarta-feira', '09:00:00', '18:00:00'),
(1, 'Quinta-feira', '09:00:00', '18:00:00'),
(1, 'Sexta-feira', '09:00:00', '18:00:00'),
(1, 'Sábado', '08:00:00', '17:00:00'),
-- Maria Estilista (id=2)
(2, 'Segunda-feira', '10:00:00', '19:00:00'),
(2, 'Terça-feira', '10:00:00', '19:00:00'),
(2, 'Quarta-feira', '10:00:00', '19:00:00'),
(2, 'Quinta-feira', '10:00:00', '19:00:00'),
(2, 'Sexta-feira', '10:00:00', '19:00:00'),
(2, 'Sábado', '09:00:00', '18:00:00');

INSERT INTO bloqueios (id_barbeiro, inicio_bloqueio, fim_bloqueio) VALUES
(1, '2025-09-24 12:00:00', '2025-09-24 13:00:00');

INSERT INTO carteiras (id_cliente, saldo) VALUES
(3, 100.00),
(4, 50.00);

INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento) VALUES
(1, 50.00, 'credito', NULL);

INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
VALUES (3, 1, 1, '2025-09-25 10:00:00', 'confirmado');

INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
VALUES (4, 2, 4, '2025-09-26 15:30:00', 'confirmado'),
       (3, 1, 2, '2025-09-24 11:00:00', 'concluido'),
       (3, 1, 3, '2025-09-27 16:00:00', 'cancelado');

INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
VALUES (1, 25.00, 'debito', 3);

INSERT INTO avaliacoes (id_cliente, id_barbeiro, id_agendamento, nota, comentario) VALUES
(3, 1, 1, 5, 'Excelente corte, muito atencioso!'),
(4, 1, 2, 4, 'O corte ficou ótimo, mas demorou um pouco.'),
(3, 1, 3, 5, 'Sempre impecável, recomendo demais!');

INSERT INTO avaliacoes (id_cliente, id_barbeiro, id_agendamento, nota, comentario) VALUES
(4, 2, 4, 5, 'Adorei a coloração, ela é uma artista.');

INSERT INTO produtos (nome, descricao, categoria, preco, estoque) VALUES
('Coca-Cola Lata', 'Refrigerante 350ml', 'bebida', 5.00, 50),
('Água Mineral', 'Água 500ml', 'bebida', 3.00, 100),
('Pomada Modeladora', 'Pomada fixação forte', 'pomada', 35.00, 20),
('Cera para Cabelo', 'Cera efeito natural', 'cera', 28.00, 15),
('Shampoo Anti-Caspa', 'Shampoo 400ml', 'shampoo', 22.00, 30),
('Pente Profissional', 'Pente de corte', 'acessorio', 15.00, 10);

-- ============================================
-- VIEWS
-- ============================================

CREATE VIEW vw_horarios_barbeiros AS
SELECT
    b.nome AS nome_barbeiro,
    h.dia_da_semana,
    h.hora_inicio,
    h.hora_fim
FROM
    horarios h
JOIN
    usuarios b ON h.id_barbeiro = b.id
ORDER BY
    b.nome, 
    FIELD(h.dia_da_semana, 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'),
    h.hora_inicio;

CREATE VIEW vw_agendamentos_detalhados AS
SELECT
    a.id AS id_agendamento,
    c.nome AS nome_cliente,
    b.nome AS nome_barbeiro,
    s.nome AS nome_servico,
    s.preco_creditos AS preco_servico,
    a.data_hora_agendamento,
    a.status
FROM
    agendamentos a
JOIN
    usuarios c ON a.id_cliente = c.id
JOIN
    usuarios b ON a.id_barbeiro = b.id
JOIN
    servicos s ON a.id_servico = s.id;

CREATE VIEW vw_faturamento_barbeiros AS
SELECT
    b.nome AS nome_barbeiro,
    COUNT(a.id) AS total_agendamentos_concluidos,
    SUM(s.preco_creditos) AS faturamento_total
FROM
    agendamentos a
JOIN
    usuarios b ON a.id_barbeiro = b.id
JOIN
    servicos s ON a.id_servico = s.id
WHERE
    a.status = 'concluido'
GROUP BY
    b.nome
ORDER BY
    faturamento_total DESC;

CREATE VIEW vw_saldo_clientes AS
SELECT
    u.nome AS nome_cliente,
    c.saldo
FROM
    carteiras c
JOIN
    usuarios u ON c.id_cliente = u.id;

CREATE VIEW vw_historico_cliente AS
SELECT
    c.nome AS nome_cliente,
    a.data_hora_agendamento,
    s.nome AS nome_servico,
    s.preco_creditos AS preco_servico,
    b.nome AS nome_barbeiro,
    a.status
FROM
    agendamentos a
JOIN
    usuarios c ON a.id_cliente = c.id
JOIN
    usuarios b ON a.id_barbeiro = b.id
JOIN
    servicos s ON a.id_servico = s.id
ORDER BY
    c.nome;

CREATE VIEW vw_avaliacoes_barbeiros AS
SELECT
    b.nome AS nome_barbeiro,
    COUNT(a.id) AS total_avaliacoes,
    AVG(a.nota) AS nota_media
FROM
    avaliacoes a
JOIN
    usuarios b ON a.id_barbeiro = b.id
GROUP BY
    b.nome
ORDER BY
    nota_media DESC;

CREATE VIEW vw_proximos_agendamentos AS
SELECT
    a.id AS id_agendamento,
    c.nome AS nome_cliente,
    b.nome AS nome_barbeiro,
    s.nome AS nome_servico,
    a.data_hora_agendamento,
    a.status
FROM
    agendamentos a
JOIN
    usuarios c ON a.id_cliente = c.id
JOIN
    usuarios b ON a.id_barbeiro = b.id
JOIN
    servicos s ON a.id_servico = s.id
WHERE
    a.status IN ('confirmado')
    AND a.data_hora_agendamento >= NOW()
ORDER BY
    a.data_hora_agendamento ASC;

CREATE VIEW vw_vendas_produtos AS
SELECT
    vp.id AS id_venda,
    c.nome AS nome_cliente,
    b.nome AS nome_barbeiro,
    p.nome AS nome_produto,
    p.categoria AS categoria_produto,
    vp.quantidade,
    vp.preco_unitario,
    vp.preco_total,
    vp.data_venda,
    a.data_hora_agendamento
FROM
    vendas_produtos vp
JOIN usuarios c ON vp.id_cliente = c.id
JOIN usuarios b ON vp.id_barbeiro = b.id
JOIN produtos p ON vp.id_produto = p.id
LEFT JOIN agendamentos a ON vp.id_agendamento = a.id
ORDER BY vp.data_venda DESC;

CREATE VIEW vw_taxas_agendamento AS
SELECT
    ta.id,
    c.nome AS nome_cliente,
    b.nome AS nome_barbeiro,
    s.nome AS nome_servico,
    a.data_hora_agendamento,
    ta.valor_servico,
    ta.taxa_garantia,
    ta.taxa_paga,
    ta.reembolsada,
    a.status AS status_agendamento,
    ta.criada_em
FROM
    taxas_agendamento ta
JOIN agendamentos a ON ta.id_agendamento = a.id
JOIN usuarios c ON a.id_cliente = c.id
JOIN usuarios b ON a.id_barbeiro = b.id
JOIN servicos s ON a.id_servico = s.id
ORDER BY ta.criada_em DESC;

CREATE VIEW vw_estoque_produtos AS
SELECT
    p.id,
    p.nome,
    p.categoria,
    p.preco,
    p.estoque,
    p.ativo,
    COALESCE(SUM(vp.quantidade), 0) AS total_vendido
FROM
    produtos p
LEFT JOIN vendas_produtos vp ON p.id = vp.id_produto
GROUP BY p.id
ORDER BY p.categoria, p.nome;

-- ============================================
-- TRIGGERS CORRIGIDOS
-- ============================================

-- Trigger condicional para débito (evita débito duplo quando controlado pela aplicação)
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

-- Trigger para reembolso quando cancelar
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

DELIMITER $$

CREATE TRIGGER trg_verificar_disponibilidade_insert
BEFORE INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_duracao_servico INT;
    DECLARE v_nome_dia VARCHAR(20);
    
    SELECT duracao_minutos INTO v_duracao_servico
    FROM servicos
    WHERE id = NEW.id_servico;
    
    -- Converte número do dia da semana para nome em português
    CASE DAYOFWEEK(NEW.data_hora_agendamento)
        WHEN 1 THEN SET v_nome_dia = 'Domingo';
        WHEN 2 THEN SET v_nome_dia = 'Segunda-feira';
        WHEN 3 THEN SET v_nome_dia = 'Terça-feira';
        WHEN 4 THEN SET v_nome_dia = 'Quarta-feira';
        WHEN 5 THEN SET v_nome_dia = 'Quinta-feira';
        WHEN 6 THEN SET v_nome_dia = 'Sexta-feira';
        WHEN 7 THEN SET v_nome_dia = 'Sábado';
    END CASE;
    
    -- Verifica se o barbeiro trabalha neste dia da semana e horário
    IF NOT EXISTS (
        SELECT 1
        FROM horarios
        WHERE id_barbeiro = NEW.id_barbeiro
          AND dia_da_semana = v_nome_dia
          AND TIME(NEW.data_hora_agendamento) >= hora_inicio
          AND ADDTIME(TIME(NEW.data_hora_agendamento), SEC_TO_TIME(v_duracao_servico * 60)) <= hora_fim
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: O horário do agendamento está fora do expediente do barbeiro.';
    END IF;
    
    -- Verifica bloqueios
    IF EXISTS (
        SELECT 1
        FROM bloqueios
        WHERE id_barbeiro = NEW.id_barbeiro
          AND NEW.data_hora_agendamento >= inicio_bloqueio
          AND NEW.data_hora_agendamento < fim_bloqueio
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: O horário do agendamento está em um período de bloqueio.';
    END IF;
    
    -- Verifica conflitos com outros agendamentos
    IF EXISTS (
        SELECT 1
        FROM agendamentos
        WHERE id_barbeiro = NEW.id_barbeiro
          AND status IN ('confirmado', 'pendente')
          AND (
              (NEW.data_hora_agendamento BETWEEN data_hora_agendamento AND DATE_ADD(data_hora_agendamento, INTERVAL v_duracao_servico MINUTE))
              OR
              (data_hora_agendamento BETWEEN NEW.data_hora_agendamento AND DATE_ADD(NEW.data_hora_agendamento, INTERVAL v_duracao_servico MINUTE))
          )
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Já existe um agendamento ocupando este horário.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_notificar_mudanca_status
AFTER UPDATE ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_mensagem_cliente VARCHAR(500);
    DECLARE v_mensagem_barbeiro VARCHAR(500);
    DECLARE v_nome_servico VARCHAR(255);
    DECLARE v_nome_cliente VARCHAR(255);
    IF OLD.status <> NEW.status THEN
        SELECT nome INTO v_nome_cliente FROM usuarios WHERE id = NEW.id_cliente;
        SELECT nome INTO v_nome_servico FROM servicos WHERE id = NEW.id_servico;
        IF NEW.status = 'confirmado' THEN
            SET v_mensagem_cliente = CONCAT('Seu agendamento para "', v_nome_servico, '" foi confirmado para ', DATE_FORMAT(NEW.data_hora_agendamento, '%d/%m/%Y às %H:%i'), '.');
            SET v_mensagem_barbeiro = CONCAT('Novo agendamento confirmado para o cliente ', v_nome_cliente, ' em ', DATE_FORMAT(NEW.data_hora_agendamento, '%d/%m/%Y às %H:%i'), '.');
            INSERT INTO notificacoes (id_usuario, mensagem, tipo) VALUES
            (NEW.id_cliente, v_mensagem_cliente, 'agendamento_confirmado'),
            (NEW.id_barbeiro, v_mensagem_barbeiro, 'agendamento_confirmado');
        ELSEIF NEW.status = 'cancelado' THEN
            SET v_mensagem_cliente = CONCAT('Seu agendamento para "', v_nome_servico, '" em ', DATE_FORMAT(NEW.data_hora_agendamento, '%d/%m/%Y às %H:%i'), ' foi cancelado.');
            SET v_mensagem_barbeiro = CONCAT('O agendamento do cliente ', v_nome_cliente, ' para ', DATE_FORMAT(NEW.data_hora_agendamento, '%d/%m/%Y às %H:%i'), ' foi cancelado.');
            INSERT INTO notificacoes (id_usuario, mensagem, tipo) VALUES
            (NEW.id_cliente, v_mensagem_cliente, 'cancelamento'),
            (NEW.id_barbeiro, v_mensagem_barbeiro, 'cancelamento');
        ELSEIF NEW.status = 'concluido' THEN
            SET v_mensagem_cliente = CONCAT('Seu agendamento para "', v_nome_servico, '" foi concluído. Obrigado!');
            SET v_mensagem_barbeiro = CONCAT('Agendamento do cliente ', v_nome_cliente, ' concluído com sucesso.');
            INSERT INTO notificacoes (id_usuario, mensagem, tipo) VALUES
            (NEW.id_cliente, v_mensagem_cliente, 'agendamento_confirmado'),
            (NEW.id_barbeiro, v_mensagem_barbeiro, 'agendamento_confirmado');
        END IF;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_reembolsar_taxa_concluido
AFTER UPDATE ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_taxa_garantia DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    IF NEW.status = 'concluido' AND OLD.status != 'concluido' THEN
        SELECT taxa_garantia INTO v_taxa_garantia
        FROM taxas_agendamento
        WHERE id_agendamento = NEW.id AND reembolsada = FALSE;
        SELECT id INTO v_id_carteira
        FROM carteiras
        WHERE id_cliente = NEW.id_cliente;
        IF v_taxa_garantia IS NOT NULL THEN
            UPDATE carteiras
            SET saldo = saldo + v_taxa_garantia
            WHERE id = v_id_carteira;
            INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
            VALUES (v_id_carteira, v_taxa_garantia, 'credito', NEW.id);
            UPDATE taxas_agendamento
            SET reembolsada = TRUE, data_reembolso = NOW()
            WHERE id_agendamento = NEW.id;
        END IF;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_atualizar_estoque_produto
AFTER INSERT ON vendas_produtos
FOR EACH ROW
BEGIN
    UPDATE produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.id_produto;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_debitar_venda_produto
AFTER INSERT ON vendas_produtos
FOR EACH ROW
BEGIN
    DECLARE v_id_carteira INT;
    SELECT id INTO v_id_carteira
    FROM carteiras
    WHERE id_cliente = NEW.id_cliente;
    UPDATE carteiras
    SET saldo = saldo - NEW.preco_total
    WHERE id = v_id_carteira;
    INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
    VALUES (v_id_carteira, NEW.preco_total, 'debito', NEW.id_agendamento);
END$$

DELIMITER ;

-- ============================================
-- PROCEDURES
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_agendar_servico(
    IN p_id_cliente INT,
    IN p_id_barbeiro INT,
    IN p_id_servico INT,
    IN p_data_hora_agendamento DATETIME
)
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_taxa_garantia DECIMAL(10, 2);
    DECLARE v_saldo_cliente DECIMAL(10, 2);
    DECLARE v_duracao_servico INT;
    DECLARE v_horario_ocupado INT DEFAULT 0;
    START TRANSACTION;
    SELECT preco_creditos, duracao_minutos INTO v_preco_servico, v_duracao_servico
    FROM servicos
    WHERE id = p_id_servico;
    SET v_taxa_garantia = v_preco_servico * 0.5;
    SELECT saldo INTO v_saldo_cliente
    FROM carteiras
    WHERE id_cliente = p_id_cliente;
    SELECT 1 INTO v_horario_ocupado
    FROM agendamentos
    WHERE id_barbeiro = p_id_barbeiro
      AND status IN ('confirmado', 'concluido')
      AND p_data_hora_agendamento BETWEEN data_hora_agendamento 
          AND DATE_ADD(data_hora_agendamento, INTERVAL v_duracao_servico MINUTE)
    LIMIT 1;
    IF v_horario_ocupado = 1 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Horário de agendamento já ocupado.';
    ELSEIF v_saldo_cliente < v_taxa_garantia THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Saldo insuficiente para pagar a taxa de garantia.';
    ELSE
        INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
        VALUES (p_id_cliente, p_id_barbeiro, p_id_servico, p_data_hora_agendamento, 'confirmado');
        COMMIT;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_vender_produto(
    IN p_id_cliente INT,
    IN p_id_barbeiro INT,
    IN p_id_produto INT,
    IN p_quantidade INT,
    IN p_id_agendamento INT
)
BEGIN
    DECLARE v_preco_unitario DECIMAL(10, 2);
    DECLARE v_preco_total DECIMAL(10, 2);
    DECLARE v_saldo_cliente DECIMAL(10, 2);
    DECLARE v_estoque_disponivel INT;
    START TRANSACTION;
    SELECT preco, estoque INTO v_preco_unitario, v_estoque_disponivel
    FROM produtos
    WHERE id = p_id_produto AND ativo = TRUE;
    IF v_estoque_disponivel < p_quantidade THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Estoque insuficiente.';
    END IF;
    SET v_preco_total = v_preco_unitario * p_quantidade;
    SELECT saldo INTO v_saldo_cliente
    FROM carteiras
    WHERE id_cliente = p_id_cliente;
    IF v_saldo_cliente < v_preco_total THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Saldo insuficiente.';
    END IF;
    INSERT INTO vendas_produtos (id_cliente, id_barbeiro, id_produto, quantidade, preco_unitario, preco_total, id_agendamento)
    VALUES (p_id_cliente, p_id_barbeiro, p_id_produto, p_quantidade, v_preco_unitario, v_preco_total, p_id_agendamento);
    COMMIT;
END$$

DELIMITER ;

-- ============================================
-- COMENTÁRIOS SOBRE AS CORREÇÕES
-- ============================================

-- PROBLEMA IDENTIFICADO:
-- O trigger anterior só debitava o valor do serviço (R$ 50,00)
-- Produtos e bebidas (R$ 4,59) não eram debitados
-- Resultado: Saldo incorreto (R$ 55,00 em vez de R$ 50,41)
-- 
-- SOLUÇÃO IMPLEMENTADA:
-- 1. Trigger condicional evita débito duplo usando @disable_trigger
-- 2. Aplicação debita valor total ANTES de criar agendamento
-- 3. Nova tabela agendamento_produtos para rastrear produtos/bebidas
-- 4. Campo descricao adicionado na tabela transacoes para melhor rastreamento

select * from usuarios;
select * from agendamentos;
select * from carteiras;