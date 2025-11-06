-- ============================================
-- BANCO DE DADOS - APP BARBEARIA
-- Sistema completo com taxas de agendamento e produtos extras
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
    papel ENUM('cliente', 'barbeiro', 'admin') NOT NULL,
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
    id_agendamento INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carteira) REFERENCES carteiras(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_agendamento) REFERENCES agendamentos(id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS horarios_disponiveis_teste (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_barbeiro INT NOT NULL,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (id_barbeiro, data, horario)
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

-- ============================================
-- INSERÇÃO DE DADOS
-- ============================================

-- Inserir usuário administrador padrão
INSERT INTO usuarios (nome, email, cpf, senha, papel) VALUES
('Administrador', 'admin@barbearia.com', '000.000.000-00', 'admin123', 'admin');

-- Inserir usuários existentes
INSERT INTO usuarios (nome, email, cpf, senha, papel) VALUES
('João Barbeiro', 'joao.barbeiro@email.com', '123.456.789-01', 'senha123', 'barbeiro'),
('Maria Estilista', 'maria.estilista@email.com', '234.567.890-12', 'senha456', 'barbeiro'),
('Pedro Cliente', 'pedro.cliente@email.com', '345.678.901-23', 'senha789', 'cliente'),
('Ana Cliente', 'ana.cliente@email.com', '456.789.012-34', 'senhaabc', 'cliente');

INSERT INTO perfis_barbeiros (id_usuario, bio, url_foto) VALUES
(2, 'Especialista em cortes clássicos e barbas modeladas. 10 anos de experiência.', 'https://exemplo.com/foto_joao.jpg'),
(3, 'Artista do cabelo feminino e masculino, com foco em novas tendências.', 'https://exemplo.com/foto_maria.jpg');

INSERT INTO servicos (id_barbeiro, nome, duracao_minutos, preco_creditos) VALUES
(2, 'Corte Clássico', 45, 30.00),
(2, 'Barba Completa', 30, 25.00),
(2, 'Corte + Barba', 75, 50.00),
(3, 'Corte Moderno', 50, 40.00),
(3, 'Coloração', 120, 150.00),
(3, 'Design de Sobrancelha', 20, 20.00);

INSERT INTO horarios (id_barbeiro, dia_da_semana, hora_inicio, hora_fim) VALUES
(2, 'Segunda-feira', '09:00:00', '18:00:00'),
(2, 'Terça-feira', '09:00:00', '18:00:00'),
(2, 'Quarta-feira', '09:00:00', '18:00:00');

INSERT INTO bloqueios (id_barbeiro, inicio_bloqueio, fim_bloqueio) VALUES
(2, '2025-09-24 12:00:00', '2025-09-24 13:00:00');

INSERT INTO carteiras (id_cliente, saldo) VALUES
(4, 100.00),
(5, 50.00);

INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento) VALUES
(1, 50.00, 'credito', NULL);

INSERT INTO horarios_disponiveis_teste (id_barbeiro, data, horario) VALUES
(2, '2025-09-25', '09:00:00'),
(2, '2025-09-25', '09:30:00'),
(2, '2025-09-25', '10:00:00'),
(2, '2025-09-25', '10:30:00'),
(2, '2025-09-25', '11:00:00'),
(2, '2025-09-25', '11:30:00'),
(2, '2025-09-25', '13:00:00'),
(2, '2025-09-25', '13:30:00'),
(2, '2025-09-25', '14:00:00'),
(2, '2025-09-25', '14:30:00'),
(2, '2025-09-25', '15:00:00'),
(2, '2025-09-25', '15:30:00'),
(2, '2025-09-25', '16:00:00'),
(2, '2025-09-25', '16:30:00'),
(2, '2025-09-25', '17:00:00'),
(2, '2025-09-25', '17:30:00');

INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
VALUES (4, 2, 1, '2025-09-25 10:00:00', 'confirmado');

INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
VALUES (5, 3, 4, '2025-09-26 15:30:00', 'confirmado'),
       (4, 2, 2, '2025-09-24 11:00:00', 'concluido'),
       (4, 2, 3, '2025-09-27 16:00:00', 'cancelado');

INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
VALUES (1, 25.00, 'debito', 3);

INSERT INTO avaliacoes (id_cliente, id_barbeiro, id_agendamento, nota, comentario) VALUES
(4, 2, 1, 5, 'Excelente corte, muito atencioso!'),
(5, 2, 2, 4, 'O corte ficou ótimo, mas demorou um pouco.'),
(4, 2, 3, 5, 'Sempre impecável, recomendo demais!');

INSERT INTO avaliacoes (id_cliente, id_barbeiro, id_agendamento, nota, comentario) VALUES
(5, 3, 4, 5, 'Adorei a coloração, ela é uma artista.');

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

CREATE VIEW vw_horarios_disponiveis_teste AS
SELECT
    b.nome AS nome_barbeiro,
    hd.data,
    hd.horario
FROM
    horarios_disponiveis_teste hd
JOIN
    usuarios b ON hd.id_barbeiro = b.id
WHERE
    hd.disponivel = TRUE
ORDER BY
    hd.data, hd.horario;

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
-- TRIGGERS
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_atualizar_horario_disponivel
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_data DATE;
    DECLARE v_horario TIME;
    SET v_data = DATE(NEW.data_hora_agendamento);
    SET v_horario = TIME(NEW.data_hora_agendamento);
    UPDATE horarios_disponiveis_teste
    SET disponivel = FALSE
    WHERE
        id_barbeiro = NEW.id_barbeiro
        AND data = v_data
        AND horario = v_horario;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_atualizar_saldo_apos_concluido
AFTER UPDATE ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    IF NEW.status = 'concluido' AND OLD.status <> 'concluido' THEN
        SELECT preco_creditos INTO v_preco_servico
        FROM servicos
        WHERE id = NEW.id_servico;
        SELECT id INTO v_id_carteira
        FROM carteiras
        WHERE id_cliente = NEW.id_cliente;
        IF v_id_carteira IS NOT NULL THEN
            UPDATE carteiras
            SET saldo = saldo - v_preco_servico
            WHERE id = v_id_carteira;
            INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
            VALUES (v_id_carteira, v_preco_servico, 'debito', NEW.id);
        END IF;
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

CREATE TRIGGER trg_verificar_disponibilidade_insert
BEFORE INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_horario_ocupado INT DEFAULT 0;
    DECLARE v_duracao_servico INT;
    DECLARE v_dia_semana VARCHAR(20);
    SELECT duracao_minutos INTO v_duracao_servico
    FROM servicos
    WHERE id = NEW.id_servico;
    SET v_dia_semana = DAYNAME(NEW.data_hora_agendamento);
    IF NOT EXISTS (
        SELECT 1
        FROM horarios
        WHERE id_barbeiro = NEW.id_barbeiro
          AND dia_da_semana = v_dia_semana
          AND TIME(NEW.data_hora_agendamento) >= hora_inicio
          AND TIME(NEW.data_hora_agendamento) < hora_fim
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: O horário do agendamento está fora do expediente do barbeiro.';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM bloqueios
        WHERE id_barbeiro = NEW.id_barbeiro
          AND NEW.data_hora_agendamento >= inicio_bloqueio
          AND NEW.data_hora_agendamento < fim_bloqueio
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: O horário do agendamento está em um período de bloqueio.';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM agendamentos
        WHERE id_barbeiro = NEW.id_barbeiro
          AND status IN ('confirmado', 'concluido')
          AND NEW.data_hora_agendamento BETWEEN data_hora_agendamento AND DATE_ADD(data_hora_agendamento, INTERVAL v_duracao_servico MINUTE)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Já existe um agendamento ocupando este horário.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_criar_taxa_agendamento
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE v_preco_servico DECIMAL(10, 2);
    DECLARE v_taxa_garantia DECIMAL(10, 2);
    DECLARE v_id_carteira INT;
    SELECT preco_creditos INTO v_preco_servico
    FROM servicos
    WHERE id = NEW.id_servico;
    SET v_taxa_garantia = v_preco_servico * 0.5;
    SELECT id INTO v_id_carteira
    FROM carteiras
    WHERE id_cliente = NEW.id_cliente;
    INSERT INTO taxas_agendamento (id_agendamento, valor_servico, taxa_garantia)
    VALUES (NEW.id, v_preco_servico, v_taxa_garantia);
    UPDATE carteiras
    SET saldo = saldo - v_taxa_garantia
    WHERE id = v_id_carteira;
    INSERT INTO transacoes (id_carteira, valor, tipo, id_agendamento)
    VALUES (v_id_carteira, v_taxa_garantia, 'debito', NEW.id);
    UPDATE taxas_agendamento
    SET taxa_paga = TRUE, data_pagamento_taxa = NOW()
    WHERE id_agendamento = NEW.id;
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
-- TRIGGER PARA VALIDAR CPF NO INSERT
-- ============================================
DELIMITER $$

CREATE TRIGGER trg_validar_cpf_insert
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    DECLARE v_cpf_limpo VARCHAR(11);
    
    -- Remove espaços em branco
    SET NEW.cpf = TRIM(NEW.cpf);
    
    -- Verifica formato (000.000.000-00 ou 00000000000)
    IF NEW.cpf NOT REGEXP '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$' 
       AND NEW.cpf NOT REGEXP '^[0-9]{11}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: CPF deve estar no formato 000.000.000-00 ou 00000000000';
    END IF;
    
    -- Formata o CPF se vier sem pontuação
    IF NEW.cpf REGEXP '^[0-9]{11}$' THEN
        SET NEW.cpf = CONCAT(
            SUBSTRING(NEW.cpf, 1, 3), '.',
            SUBSTRING(NEW.cpf, 4, 3), '.',
            SUBSTRING(NEW.cpf, 7, 3), '-',
            SUBSTRING(NEW.cpf, 10, 2)
        );
    END IF;
    
    -- Valida o CPF usando a função
    IF NOT fn_validar_cpf(NEW.cpf) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: CPF inválido';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- TRIGGER PARA VALIDAR CPF NO UPDATE
-- ============================================
DELIMITER $$

CREATE TRIGGER trg_validar_cpf_update
BEFORE UPDATE ON usuarios
FOR EACH ROW
BEGIN
    DECLARE v_cpf_limpo VARCHAR(11);
    
    -- Só valida se o CPF foi alterado
    IF NEW.cpf != OLD.cpf THEN
        -- Remove espaços em branco
        SET NEW.cpf = TRIM(NEW.cpf);
        
        -- Verifica formato
        IF NEW.cpf NOT REGEXP '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$' 
           AND NEW.cpf NOT REGEXP '^[0-9]{11}$' THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Erro: CPF deve estar no formato 000.000.000-00 ou 00000000000';
        END IF;
        
        -- Formata o CPF se vier sem pontuação
        IF NEW.cpf REGEXP '^[0-9]{11}$' THEN
            SET NEW.cpf = CONCAT(
                SUBSTRING(NEW.cpf, 1, 3), '.',
                SUBSTRING(NEW.cpf, 4, 3), '.',
                SUBSTRING(NEW.cpf, 7, 3), '-',
                SUBSTRING(NEW.cpf, 10, 2)
            );
        END IF;
        
        -- Valida o CPF
        IF NOT fn_validar_cpf(NEW.cpf) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Erro: CPF inválido';
        END IF;
    END IF;
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

DELIMITER $$

CREATE PROCEDURE sp_cadastrar_usuario(
    IN p_nome VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_cpf VARCHAR(14),
    IN p_senha VARCHAR(255),
    IN p_papel ENUM('cliente', 'barbeiro', 'admin')
)
BEGIN
    DECLARE v_cpf_existe INT DEFAULT 0;
    DECLARE v_email_existe INT DEFAULT 0;
    
    START TRANSACTION;
    
    -- Verifica se CPF já existe
    SELECT COUNT(*) INTO v_cpf_existe
    FROM usuarios
    WHERE cpf = p_cpf;
    
    IF v_cpf_existe > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: CPF já cadastrado no sistema';
    END IF;
    
    -- Verifica se email já existe
    SELECT COUNT(*) INTO v_email_existe
    FROM usuarios
    WHERE email = p_email;
    
    IF v_email_existe > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Email já cadastrado no sistema';
    END IF;
    
    -- Insere o usuário (o trigger vai validar o CPF)
    INSERT INTO usuarios (nome, email, cpf, senha, papel)
    VALUES (p_nome, p_email, p_cpf, p_senha, p_papel);
    
    -- Se for cliente, cria a carteira automaticamente
    IF p_papel = 'cliente' THEN
        INSERT INTO carteiras (id_cliente, saldo)
        VALUES (LAST_INSERT_ID(), 0.00);
    END IF;
    
    COMMIT;
    
    SELECT LAST_INSERT_ID() AS id_usuario, 'Usuário cadastrado com sucesso!' AS mensagem;
END$$

DELIMITER ;

-- ============================================
-- FUNÇÕES
-- ============================================

DELIMITER $$

CREATE FUNCTION fn_validar_cpf(p_cpf VARCHAR(14))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_cpf_numeros VARCHAR(11);
    DECLARE v_soma INT DEFAULT 0;
    DECLARE v_resto INT;
    DECLARE v_digito1 INT;
    DECLARE v_digito2 INT;
    DECLARE v_i INT;
    DECLARE v_todos_iguais BOOLEAN DEFAULT TRUE;
    
    -- Remove pontos e traço, mantendo apenas números
    SET v_cpf_numeros = REPLACE(REPLACE(p_cpf, '.', ''), '-', '');
    
    -- Verifica se tem exatamente 11 dígitos
    IF LENGTH(v_cpf_numeros) != 11 OR v_cpf_numeros NOT REGEXP '^[0-9]{11}$' THEN
        RETURN FALSE;
    END IF;
    
    -- Verifica se todos os dígitos são iguais (CPFs inválidos conhecidos)
    SET v_i = 1;
    WHILE v_i <= 10 DO
        IF SUBSTRING(v_cpf_numeros, v_i, 1) != SUBSTRING(v_cpf_numeros, v_i + 1, 1) THEN
            SET v_todos_iguais = FALSE;
        END IF;
        SET v_i = v_i + 1;
    END WHILE;
    
    IF v_todos_iguais THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula o primeiro dígito verificador
    SET v_soma = 0;
    SET v_i = 1;
    WHILE v_i <= 9 DO
        SET v_soma = v_soma + (CAST(SUBSTRING(v_cpf_numeros, v_i, 1) AS UNSIGNED) * (11 - v_i));
        SET v_i = v_i + 1;
    END WHILE;
    
    SET v_resto = v_soma % 11;
    IF v_resto < 2 THEN
        SET v_digito1 = 0;
    ELSE
        SET v_digito1 = 11 - v_resto;
    END IF;
    
    -- Verifica o primeiro dígito
    IF v_digito1 != CAST(SUBSTRING(v_cpf_numeros, 10, 1) AS UNSIGNED) THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula o segundo dígito verificador
    SET v_soma = 0;
    SET v_i = 1;
    WHILE v_i <= 10 DO
        SET v_soma = v_soma + (CAST(SUBSTRING(v_cpf_numeros, v_i, 1) AS UNSIGNED) * (12 - v_i));
        SET v_i = v_i + 1;
    END WHILE;
    
    SET v_resto = v_soma % 11;
    IF v_resto < 2 THEN
        SET v_digito2 = 0;
    ELSE
        SET v_digito2 = 11 - v_resto;
    END IF;
    
    -- Verifica o segundo dígito
    IF v_digito2 != CAST(SUBSTRING(v_cpf_numeros, 11, 1) AS UNSIGNED) THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END$$

DELIMITER ;

SELECT * FROM usuarios;