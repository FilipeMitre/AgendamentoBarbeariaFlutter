-- ============================================
-- BANCO DE DADOS - SISTEMA DE BARBEARIA (VERSÃO SIMPLIFICADA)
-- Apenas com os essenciais para testar
-- ============================================

DROP DATABASE IF EXISTS barbearia_app;
CREATE DATABASE barbearia_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE barbearia_app;

-- ============================================
-- TABELAS
-- ============================================

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(14) UNIQUE NULL,
    senha_hash VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('cliente', 'barbeiro', 'admin') DEFAULT 'cliente',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_cpf (cpf),
    INDEX idx_tipo (tipo_usuario),
    INDEX idx_ativo (ativo),
    CONSTRAINT chk_cpf_formato CHECK (cpf IS NULL OR cpf REGEXP '^[0-9]{11}$|^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE carteiras (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT UNIQUE NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    CONSTRAINT chk_saldo_positivo CHECK (saldo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE servicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_base DECIMAL(10, 2) NOT NULL,
    duracao_minutos INT NOT NULL DEFAULT 30,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ativo (ativo),
    CONSTRAINT chk_preco_positivo CHECK (preco_base > 0),
    CONSTRAINT chk_duracao_positiva CHECK (duracao_minutos > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE barbeiro_servicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    barbeiro_id INT NOT NULL,
    servico_id INT NOT NULL,
    preco_personalizado DECIMAL(10, 2) NULL,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (barbeiro_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (servico_id) REFERENCES servicos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_barbeiro_servico (barbeiro_id, servico_id),
    INDEX idx_barbeiro (barbeiro_id),
    INDEX idx_servico (servico_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE horarios_funcionamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dia_semana ENUM('domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado') NOT NULL UNIQUE,
    horario_abertura TIME NOT NULL DEFAULT '08:00:00',
    horario_fechamento TIME NOT NULL DEFAULT '19:00:00',
    ativo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE disponibilidade_barbeiro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    barbeiro_id INT NOT NULL,
    dia_semana ENUM('domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado') NOT NULL,
    horario TIME NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (barbeiro_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_barbeiro_dia_horario (barbeiro_id, dia_semana, horario),
    INDEX idx_barbeiro (barbeiro_id),
    INDEX idx_dia (dia_semana),
    INDEX idx_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE agendamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    barbeiro_id INT NOT NULL,
    servico_id INT NOT NULL,
    data_agendamento DATE NOT NULL,
    horario TIME NOT NULL,
    valor_servico DECIMAL(10, 2) NOT NULL,
    valor_comissao DECIMAL(10, 2) NOT NULL,
    valor_barbeiro DECIMAL(10, 2) NOT NULL,
    status ENUM('pendente', 'confirmado', 'concluido', 'cancelado') DEFAULT 'confirmado',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_conclusao TIMESTAMP NULL,
    data_cancelamento TIMESTAMP NULL,
    motivo_cancelamento TEXT NULL,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (barbeiro_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (servico_id) REFERENCES servicos(id) ON DELETE RESTRICT,
    INDEX idx_cliente (cliente_id),
    INDEX idx_barbeiro (barbeiro_id),
    INDEX idx_data (data_agendamento),
    INDEX idx_status (status),
    INDEX idx_data_horario (data_agendamento, horario),
    CONSTRAINT chk_cliente_diferente_barbeiro CHECK (cliente_id != barbeiro_id),
    CONSTRAINT chk_valores_positivos CHECK (valor_servico > 0 AND valor_comissao >= 0 AND valor_barbeiro >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE transacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    carteira_id INT NOT NULL,
    tipo_transacao ENUM('recarga', 'pagamento', 'recebimento', 'estorno', 'taxa_cancelamento', 'comissao') NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    saldo_anterior DECIMAL(10, 2) NOT NULL,
    saldo_posterior DECIMAL(10, 2) NOT NULL,
    descricao TEXT,
    agendamento_id INT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carteira_id) REFERENCES carteiras(id) ON DELETE CASCADE,
    FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id) ON DELETE SET NULL,
    INDEX idx_carteira (carteira_id),
    INDEX idx_tipo (tipo_transacao),
    INDEX idx_data (data_transacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE avaliacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agendamento_id INT UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    barbeiro_id INT NOT NULL,
    nota INT NOT NULL,
    comentario TEXT NULL,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (barbeiro_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_barbeiro (barbeiro_id),
    INDEX idx_nota (nota),
    CONSTRAINT chk_nota_valida CHECK (nota >= 1 AND nota <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE notificacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    tipo ENUM('novo_agendamento', 'cancelamento', 'confirmacao', 'lembrete', 'avaliacao', 'sistema') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensagem TEXT NOT NULL,
    agendamento_id INT NULL,
    lida BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_lida (lida),
    INDEX idx_data (data_criacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE configuracoes_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor VARCHAR(255) NOT NULL,
    descricao TEXT,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE categorias_produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo ENUM('produto', 'bebida') NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tipo (tipo),
    INDEX idx_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT DEFAULT 0,
    imagem_url VARCHAR(500),
    ativo BOOLEAN DEFAULT TRUE,
    destaque BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias_produto(id) ON DELETE RESTRICT,
    INDEX idx_categoria (categoria_id),
    INDEX idx_ativo (ativo),
    INDEX idx_destaque (destaque),
    CONSTRAINT chk_preco_produto_positivo CHECK (preco > 0),
    CONSTRAINT chk_estoque_positivo CHECK (estoque >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE vendas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    agendamento_id INT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    status ENUM('pendente', 'pago', 'cancelado') DEFAULT 'pendente',
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_pagamento TIMESTAMP NULL,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id) ON DELETE SET NULL,
    INDEX idx_cliente (cliente_id),
    INDEX idx_agendamento (agendamento_id),
    INDEX idx_status (status),
    INDEX idx_data (data_venda),
    CONSTRAINT chk_valor_venda_positivo CHECK (valor_total > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE itens_venda (
    id INT PRIMARY KEY AUTO_INCREMENT,
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (venda_id) REFERENCES vendas(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT,
    INDEX idx_venda (venda_id),
    INDEX idx_produto (produto_id),
    CONSTRAINT chk_quantidade_positiva CHECK (quantidade > 0),
    CONSTRAINT chk_preco_item_positivo CHECK (preco_unitario > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE recomendacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    produto_id INT NULL,
    tipo ENUM('produto', 'bebida', 'combo') NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    ordem INT DEFAULT 0,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE SET NULL,
    INDEX idx_tipo (tipo),
    INDEX idx_ativo (ativo),
    INDEX idx_ordem (ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TRIGGERS
-- ============================================

DELIMITER //
CREATE TRIGGER trg_criar_carteira_usuario
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO carteiras (usuario_id, saldo) VALUES (NEW.id, 0.00);
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_validar_horario_agendamento
BEFORE INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE dia_semana_agendamento VARCHAR(20);
    DECLARE horario_abre TIME;
    DECLARE horario_fecha TIME;
    DECLARE funcionamento_ativo BOOLEAN;

    SET dia_semana_agendamento = CASE DAYOFWEEK(NEW.data_agendamento)
        WHEN 1 THEN 'domingo'
        WHEN 2 THEN 'segunda'
        WHEN 3 THEN 'terca'
        WHEN 4 THEN 'quarta'
        WHEN 5 THEN 'quinta'
        WHEN 6 THEN 'sexta'
        WHEN 7 THEN 'sabado'
    END;

    SELECT horario_abertura, horario_fechamento, ativo
    INTO horario_abre, horario_fecha, funcionamento_ativo
    FROM horarios_funcionamento
    WHERE dia_semana = dia_semana_agendamento;

    IF NOT funcionamento_ativo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Barbearia não funciona neste dia da semana';
    END IF;

    IF NEW.horario < horario_abre OR NEW.horario >= horario_fecha THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Horário fora do expediente da barbearia';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_validar_disponibilidade_barbeiro
BEFORE INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE dia_semana_agendamento VARCHAR(20);
    DECLARE disponivel INT;

    SET dia_semana_agendamento = CASE DAYOFWEEK(NEW.data_agendamento)
        WHEN 1 THEN 'domingo'
        WHEN 2 THEN 'segunda'
        WHEN 3 THEN 'terca'
        WHEN 4 THEN 'quarta'
        WHEN 5 THEN 'quinta'
        WHEN 6 THEN 'sexta'
        WHEN 7 THEN 'sabado'
    END;

    SELECT COUNT(*) INTO disponivel
    FROM disponibilidade_barbeiro
    WHERE barbeiro_id = NEW.barbeiro_id
        AND dia_semana = dia_semana_agendamento
        AND horario = NEW.horario
        AND ativo = TRUE;

    IF disponivel = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Barbeiro não disponível neste horário';
    END IF;

    IF EXISTS (
        SELECT 1 FROM agendamentos
        WHERE barbeiro_id = NEW.barbeiro_id
            AND data_agendamento = NEW.data_agendamento
            AND horario = NEW.horario
            AND status IN ('confirmado', 'pendente')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Já existe agendamento para este horário';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_notificar_barbeiro_agendamento
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE nome_cliente VARCHAR(100);
    DECLARE nome_servico VARCHAR(100);

    SELECT nome INTO nome_cliente FROM usuarios WHERE id = NEW.cliente_id;
    SELECT nome INTO nome_servico FROM servicos WHERE id = NEW.servico_id;

    INSERT INTO notificacoes (usuario_id, tipo, titulo, mensagem, agendamento_id)
    VALUES (
        NEW.barbeiro_id,
        'novo_agendamento',
        'Novo Agendamento!',
        CONCAT('Você tem um novo agendamento com ', nome_cliente, ' para ', nome_servico, ' em ', DATE_FORMAT(NEW.data_agendamento, '%d/%m/%Y'), ' às ', TIME_FORMAT(NEW.horario, '%H:%i')),
        NEW.id
    );
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_notificar_cliente_agendamento
AFTER INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE nome_barbeiro VARCHAR(100);
    DECLARE nome_servico VARCHAR(100);

    SELECT nome INTO nome_barbeiro FROM usuarios WHERE id = NEW.barbeiro_id;
    SELECT nome INTO nome_servico FROM servicos WHERE id = NEW.servico_id;

    INSERT INTO notificacoes (usuario_id, tipo, titulo, mensagem, agendamento_id)
    VALUES (
        NEW.cliente_id,
        'confirmacao',
        'Agendamento Confirmado!',
        CONCAT('Seu agendamento de ', nome_servico, ' com ', nome_barbeiro, ' foi confirmado para ', DATE_FORMAT(NEW.data_agendamento, '%d/%m/%Y'), ' às ', TIME_FORMAT(NEW.horario, '%H:%i')),
        NEW.id
    );
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_registrar_transacao_carteira
AFTER UPDATE ON carteiras
FOR EACH ROW
BEGIN
    IF OLD.saldo != NEW.saldo THEN
        INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
        VALUES (
            NEW.id,
            'recarga',
            NEW.saldo - OLD.saldo,
            OLD.saldo,
            NEW.saldo,
            'Recarga de créditos'
        );
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_atualizar_estoque_venda
AFTER INSERT ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;

    IF (SELECT estoque FROM produtos WHERE id = NEW.produto_id) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente para este produto';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_restaurar_estoque_cancelamento
AFTER UPDATE ON vendas
FOR EACH ROW
BEGIN
    IF OLD.status != 'cancelado' AND NEW.status = 'cancelado' THEN
        UPDATE produtos p
        INNER JOIN itens_venda iv ON iv.produto_id = p.id
        SET p.estoque = p.estoque + iv.quantidade
        WHERE iv.venda_id = NEW.id;
    END IF;
END//
DELIMITER ;

-- ============================================
-- DADOS INICIAIS
-- ============================================

INSERT INTO horarios_funcionamento (dia_semana, horario_abertura, horario_fechamento, ativo) VALUES
('domingo', '08:00:00', '19:00:00', FALSE),
('segunda', '08:00:00', '19:00:00', TRUE),
('terca', '08:00:00', '19:00:00', TRUE),
('quarta', '08:00:00', '19:00:00', TRUE),
('quinta', '08:00:00', '19:00:00', TRUE),
('sexta', '08:00:00', '19:00:00', TRUE),
('sabado', '08:00:00', '19:00:00', TRUE);

INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos) VALUES
('Corte Masculino', 'Corte de cabelo masculino tradicional', 35.00, 30),
('Barba', 'Aparar e modelar barba', 25.00, 30),
('Corte + Barba (Completo)', 'Pacote completo: corte e barba', 50.00, 60),
('Corte Feminino', 'Corte de cabelo feminino', 45.00, 60),
('Coloração', 'Tintura e coloração de cabelo', 80.00, 90),
('Hidratação', 'Tratamento de hidratação capilar', 60.00, 60),
('Escova', 'Escova modeladora', 40.00, 30),
('Luzes/Mechas', 'Aplicação de luzes ou mechas', 120.00, 120);

INSERT INTO configuracoes_sistema (chave, valor, descricao) VALUES
('taxa_comissao_admin', '5', 'Porcentagem de comissão do admin sobre cada serviço (%)'),
('prazo_cancelamento_horas', '2', 'Prazo mínimo em horas para cancelamento sem taxa'),
('taxa_cancelamento_tardio', '10', 'Porcentagem cobrada em cancelamentos tardios (%)'),
('intervalo_agendamento_minutos', '30', 'Intervalo padrão entre agendamentos (minutos)');

INSERT INTO categorias_produto (nome, descricao, tipo) VALUES
('Cremes e Pomadas', 'Produtos para modelagem e finalização de cabelo', 'produto'),
('Gel para Cabelo', 'Géis fixadores e modeladores', 'produto'),
('Esponjas e Acessórios', 'Acessórios para cuidados capilares', 'produto'),
('Cervejas', 'Cervejas nacionais e importadas', 'bebida'),
('Refrigerantes', 'Refrigerantes e bebidas gaseificadas', 'bebida'),
('Águas', 'Águas minerais e saborizadas', 'bebida');

INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo, destaque) VALUES
(1, 'Creme de cabelo(cachop)', 'Creme modelador para cabelos cacheados', 27.99, 50, TRUE, TRUE),
(2, 'gel para cabelo', 'Gel fixador extra forte', 15.99, 80, TRUE, TRUE),
(3, 'Esponja Nudred', 'Esponja twist para cabelos cacheados', 24.99, 30, TRUE, FALSE),
(3, 'Pata Pata', 'Escova modeladora profissional', 4.99, 25, TRUE, FALSE),
(4, 'Cerveja lata 350 ml', 'Cerveja pilsen gelada', 8.99, 100, TRUE, TRUE),
(4, 'Cerveja zero álcool', 'Cerveja sem álcool 350ml', 15.99, 60, TRUE, FALSE),
(5, 'Refrigerante lata 350 ml', 'Refrigerante cola gelado', 6.99, 120, TRUE, TRUE),
(6, 'Água mineral 500ml', 'Água mineral natural', 3.50, 150, TRUE, FALSE);

INSERT INTO recomendacoes (titulo, descricao, produto_id, tipo, ativo, ordem) VALUES
('Produtos', 'Cremes de cabelo, gel e outros', NULL, 'produto', TRUE, 1),
('Bebidas', 'Cervejas, refrigerante e outras', NULL, 'bebida', TRUE, 2);

-- ============================================
-- BARBEIROS E DISPONIBILIDADES
-- ============================================

INSERT INTO usuarios (id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES
(2, 'Haku Santos', 'haku@goatbarber.com', '(71) 98765-4321', '12345678901', SHA2('senha123', 256), 'barbeiro', TRUE),
(3, 'Luon Yog', 'luon@goatbarber.com', '(71) 98765-4322', '12345678902', SHA2('senha123', 256), 'barbeiro', TRUE),
(4, 'Oui Uiga', 'oui@goatbarber.com', '(71) 98765-4323', '12345678903', SHA2('senha123', 256), 'barbeiro', TRUE);

INSERT INTO barbeiro_servicos (barbeiro_id, servico_id, preco_personalizado, ativo) VALUES
(2, 1, 35.00, TRUE), (2, 2, 25.00, TRUE), (2, 3, 50.00, TRUE), (2, 4, 45.00, TRUE), (2, 5, 80.00, TRUE), (2, 6, 60.00, TRUE),
(3, 1, 35.00, TRUE), (3, 2, 25.00, TRUE), (3, 3, 50.00, TRUE), (3, 4, 45.00, TRUE), (3, 5, 80.00, TRUE), (3, 7, 40.00, TRUE),
(4, 1, 35.00, TRUE), (4, 2, 25.00, TRUE), (4, 3, 50.00, TRUE), (4, 4, 45.00, TRUE), (4, 6, 60.00, TRUE), (4, 8, 120.00, TRUE);

INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo) VALUES
(2,'segunda','08:00',TRUE),(2,'segunda','08:30',TRUE),(2,'segunda','09:00',TRUE),(2,'segunda','09:30',TRUE),(2,'segunda','10:00',TRUE),(2,'segunda','10:30',TRUE),(2,'segunda','11:00',TRUE),(2,'segunda','11:30',TRUE),(2,'segunda','12:00',TRUE),(2,'segunda','12:30',TRUE),(2,'segunda','13:00',TRUE),(2,'segunda','13:30',TRUE),(2,'segunda','14:00',TRUE),(2,'segunda','14:30',TRUE),(2,'segunda','15:00',TRUE),(2,'segunda','15:30',TRUE),(2,'segunda','16:00',TRUE),(2,'segunda','16:30',TRUE),(2,'segunda','17:00',TRUE),(2,'segunda','17:30',TRUE),
(2,'terca','08:00',TRUE),(2,'terca','08:30',TRUE),(2,'terca','09:00',TRUE),(2,'terca','09:30',TRUE),(2,'terca','10:00',TRUE),(2,'terca','10:30',TRUE),(2,'terca','11:00',TRUE),(2,'terca','11:30',TRUE),(2,'terca','12:00',TRUE),(2,'terca','12:30',TRUE),(2,'terca','13:00',TRUE),(2,'terca','13:30',TRUE),(2,'terca','14:00',TRUE),(2,'terca','14:30',TRUE),(2,'terca','15:00',TRUE),(2,'terca','15:30',TRUE),(2,'terca','16:00',TRUE),(2,'terca','16:30',TRUE),(2,'terca','17:00',TRUE),(2,'terca','17:30',TRUE),
(2,'quarta','08:00',TRUE),(2,'quarta','08:30',TRUE),(2,'quarta','09:00',TRUE),(2,'quarta','09:30',TRUE),(2,'quarta','10:00',TRUE),(2,'quarta','10:30',TRUE),(2,'quarta','11:00',TRUE),(2,'quarta','11:30',TRUE),(2,'quarta','12:00',TRUE),(2,'quarta','12:30',TRUE),(2,'quarta','13:00',TRUE),(2,'quarta','13:30',TRUE),(2,'quarta','14:00',TRUE),(2,'quarta','14:30',TRUE),(2,'quarta','15:00',TRUE),(2,'quarta','15:30',TRUE),(2,'quarta','16:00',TRUE),(2,'quarta','16:30',TRUE),(2,'quarta','17:00',TRUE),(2,'quarta','17:30',TRUE),
(2,'quinta','08:00',TRUE),(2,'quinta','08:30',TRUE),(2,'quinta','09:00',TRUE),(2,'quinta','09:30',TRUE),(2,'quinta','10:00',TRUE),(2,'quinta','10:30',TRUE),(2,'quinta','11:00',TRUE),(2,'quinta','11:30',TRUE),(2,'quinta','12:00',TRUE),(2,'quinta','12:30',TRUE),(2,'quinta','13:00',TRUE),(2,'quinta','13:30',TRUE),(2,'quinta','14:00',TRUE),(2,'quinta','14:30',TRUE),(2,'quinta','15:00',TRUE),(2,'quinta','15:30',TRUE),(2,'quinta','16:00',TRUE),(2,'quinta','16:30',TRUE),(2,'quinta','17:00',TRUE),(2,'quinta','17:30',TRUE),
(2,'sexta','08:00',TRUE),(2,'sexta','08:30',TRUE),(2,'sexta','09:00',TRUE),(2,'sexta','09:30',TRUE),(2,'sexta','10:00',TRUE),(2,'sexta','10:30',TRUE),(2,'sexta','11:00',TRUE),(2,'sexta','11:30',TRUE),(2,'sexta','12:00',TRUE),(2,'sexta','12:30',TRUE),(2,'sexta','13:00',TRUE),(2,'sexta','13:30',TRUE),(2,'sexta','14:00',TRUE),(2,'sexta','14:30',TRUE),(2,'sexta','15:00',TRUE),(2,'sexta','15:30',TRUE),(2,'sexta','16:00',TRUE),(2,'sexta','16:30',TRUE),(2,'sexta','17:00',TRUE),(2,'sexta','17:30',TRUE),
(2,'sabado','09:00',TRUE),(2,'sabado','09:30',TRUE),(2,'sabado','10:00',TRUE),(2,'sabado','10:30',TRUE),(2,'sabado','11:00',TRUE),(2,'sabado','11:30',TRUE),(2,'sabado','12:00',TRUE),(2,'sabado','12:30',TRUE),(2,'sabado','13:00',TRUE),(2,'sabado','13:30',TRUE),(2,'sabado','14:00',TRUE),(2,'sabado','14:30',TRUE),(2,'sabado','15:00',TRUE),(2,'sabado','15:30',TRUE),(2,'sabado','16:00',TRUE),(2,'sabado','16:30',TRUE),
(3,'segunda','08:00',TRUE),(3,'segunda','08:30',TRUE),(3,'segunda','09:00',TRUE),(3,'segunda','09:30',TRUE),(3,'segunda','10:00',TRUE),(3,'segunda','10:30',TRUE),(3,'segunda','11:00',TRUE),(3,'segunda','11:30',TRUE),(3,'segunda','12:00',TRUE),(3,'segunda','12:30',TRUE),(3,'segunda','13:00',TRUE),(3,'segunda','13:30',TRUE),(3,'segunda','14:00',TRUE),(3,'segunda','14:30',TRUE),(3,'segunda','15:00',TRUE),(3,'segunda','15:30',TRUE),(3,'segunda','16:00',TRUE),(3,'segunda','16:30',TRUE),(3,'segunda','17:00',TRUE),(3,'segunda','17:30',TRUE),
(3,'terca','08:00',TRUE),(3,'terca','08:30',TRUE),(3,'terca','09:00',TRUE),(3,'terca','09:30',TRUE),(3,'terca','10:00',TRUE),(3,'terca','10:30',TRUE),(3,'terca','11:00',TRUE),(3,'terca','11:30',TRUE),(3,'terca','12:00',TRUE),(3,'terca','12:30',TRUE),(3,'terca','13:00',TRUE),(3,'terca','13:30',TRUE),(3,'terca','14:00',TRUE),(3,'terca','14:30',TRUE),(3,'terca','15:00',TRUE),(3,'terca','15:30',TRUE),(3,'terca','16:00',TRUE),(3,'terca','16:30',TRUE),(3,'terca','17:00',TRUE),(3,'terca','17:30',TRUE),
(3,'quarta','08:00',TRUE),(3,'quarta','08:30',TRUE),(3,'quarta','09:00',TRUE),(3,'quarta','09:30',TRUE),(3,'quarta','10:00',TRUE),(3,'quarta','10:30',TRUE),(3,'quarta','11:00',TRUE),(3,'quarta','11:30',TRUE),(3,'quarta','12:00',TRUE),(3,'quarta','12:30',TRUE),(3,'quarta','13:00',TRUE),(3,'quarta','13:30',TRUE),(3,'quarta','14:00',TRUE),(3,'quarta','14:30',TRUE),(3,'quarta','15:00',TRUE),(3,'quarta','15:30',TRUE),(3,'quarta','16:00',TRUE),(3,'quarta','16:30',TRUE),(3,'quarta','17:00',TRUE),(3,'quarta','17:30',TRUE),
(3,'quinta','08:00',TRUE),(3,'quinta','08:30',TRUE),(3,'quinta','09:00',TRUE),(3,'quinta','09:30',TRUE),(3,'quinta','10:00',TRUE),(3,'quinta','10:30',TRUE),(3,'quinta','11:00',TRUE),(3,'quinta','11:30',TRUE),(3,'quinta','12:00',TRUE),(3,'quinta','12:30',TRUE),(3,'quinta','13:00',TRUE),(3,'quinta','13:30',TRUE),(3,'quinta','14:00',TRUE),(3,'quinta','14:30',TRUE),(3,'quinta','15:00',TRUE),(3,'quinta','15:30',TRUE),(3,'quinta','16:00',TRUE),(3,'quinta','16:30',TRUE),(3,'quinta','17:00',TRUE),(3,'quinta','17:30',TRUE),
(3,'sexta','08:00',TRUE),(3,'sexta','08:30',TRUE),(3,'sexta','09:00',TRUE),(3,'sexta','09:30',TRUE),(3,'sexta','10:00',TRUE),(3,'sexta','10:30',TRUE),(3,'sexta','11:00',TRUE),(3,'sexta','11:30',TRUE),(3,'sexta','12:00',TRUE),(3,'sexta','12:30',TRUE),(3,'sexta','13:00',TRUE),(3,'sexta','13:30',TRUE),(3,'sexta','14:00',TRUE),(3,'sexta','14:30',TRUE),(3,'sexta','15:00',TRUE),(3,'sexta','15:30',TRUE),(3,'sexta','16:00',TRUE),(3,'sexta','16:30',TRUE),(3,'sexta','17:00',TRUE),(3,'sexta','17:30',TRUE),
(3,'sabado','09:00',TRUE),(3,'sabado','09:30',TRUE),(3,'sabado','10:00',TRUE),(3,'sabado','10:30',TRUE),(3,'sabado','11:00',TRUE),(3,'sabado','11:30',TRUE),(3,'sabado','12:00',TRUE),(3,'sabado','12:30',TRUE),(3,'sabado','13:00',TRUE),(3,'sabado','13:30',TRUE),(3,'sabado','14:00',TRUE),(3,'sabado','14:30',TRUE),(3,'sabado','15:00',TRUE),(3,'sabado','15:30',TRUE),(3,'sabado','16:00',TRUE),(3,'sabado','16:30',TRUE),
(4,'segunda','08:00',TRUE),(4,'segunda','08:30',TRUE),(4,'segunda','09:00',TRUE),(4,'segunda','09:30',TRUE),(4,'segunda','10:00',TRUE),(4,'segunda','10:30',TRUE),(4,'segunda','11:00',TRUE),(4,'segunda','11:30',TRUE),(4,'segunda','12:00',TRUE),(4,'segunda','12:30',TRUE),(4,'segunda','13:00',TRUE),(4,'segunda','13:30',TRUE),(4,'segunda','14:00',TRUE),(4,'segunda','14:30',TRUE),(4,'segunda','15:00',TRUE),(4,'segunda','15:30',TRUE),(4,'segunda','16:00',TRUE),(4,'segunda','16:30',TRUE),(4,'segunda','17:00',TRUE),(4,'segunda','17:30',TRUE),
(4,'terca','08:00',TRUE),(4,'terca','08:30',TRUE),(4,'terca','09:00',TRUE),(4,'terca','09:30',TRUE),(4,'terca','10:00',TRUE),(4,'terca','10:30',TRUE),(4,'terca','11:00',TRUE),(4,'terca','11:30',TRUE),(4,'terca','12:00',TRUE),(4,'terca','12:30',TRUE),(4,'terca','13:00',TRUE),(4,'terca','13:30',TRUE),(4,'terca','14:00',TRUE),(4,'terca','14:30',TRUE),(4,'terca','15:00',TRUE),(4,'terca','15:30',TRUE),(4,'terca','16:00',TRUE),(4,'terca','16:30',TRUE),(4,'terca','17:00',TRUE),(4,'terca','17:30',TRUE),
(4,'quarta','08:00',TRUE),(4,'quarta','08:30',TRUE),(4,'quarta','09:00',TRUE),(4,'quarta','09:30',TRUE),(4,'quarta','10:00',TRUE),(4,'quarta','10:30',TRUE),(4,'quarta','11:00',TRUE),(4,'quarta','11:30',TRUE),(4,'quarta','12:00',TRUE),(4,'quarta','12:30',TRUE),(4,'quarta','13:00',TRUE),(4,'quarta','13:30',TRUE),(4,'quarta','14:00',TRUE),(4,'quarta','14:30',TRUE),(4,'quarta','15:00',TRUE),(4,'quarta','15:30',TRUE),(4,'quarta','16:00',TRUE),(4,'quarta','16:30',TRUE),(4,'quarta','17:00',TRUE),(4,'quarta','17:30',TRUE),
(4,'quinta','08:00',TRUE),(4,'quinta','08:30',TRUE),(4,'quinta','09:00',TRUE),(4,'quinta','09:30',TRUE),(4,'quinta','10:00',TRUE),(4,'quinta','10:30',TRUE),(4,'quinta','11:00',TRUE),(4,'quinta','11:30',TRUE),(4,'quinta','12:00',TRUE),(4,'quinta','12:30',TRUE),(4,'quinta','13:00',TRUE),(4,'quinta','13:30',TRUE),(4,'quinta','14:00',TRUE),(4,'quinta','14:30',TRUE),(4,'quinta','15:00',TRUE),(4,'quinta','15:30',TRUE),(4,'quinta','16:00',TRUE),(4,'quinta','16:30',TRUE),(4,'quinta','17:00',TRUE),(4,'quinta','17:30',TRUE),
(4,'sexta','08:00',TRUE),(4,'sexta','08:30',TRUE),(4,'sexta','09:00',TRUE),(4,'sexta','09:30',TRUE),(4,'sexta','10:00',TRUE),(4,'sexta','10:30',TRUE),(4,'sexta','11:00',TRUE),(4,'sexta','11:30',TRUE),(4,'sexta','12:00',TRUE),(4,'sexta','12:30',TRUE),(4,'sexta','13:00',TRUE),(4,'sexta','13:30',TRUE),(4,'sexta','14:00',TRUE),(4,'sexta','14:30',TRUE),(4,'sexta','15:00',TRUE),(4,'sexta','15:30',TRUE),(4,'sexta','16:00',TRUE),(4,'sexta','16:30',TRUE),(4,'sexta','17:00',TRUE),(4,'sexta','17:30',TRUE),
(4,'sabado','09:00',TRUE),(4,'sabado','09:30',TRUE),(4,'sabado','10:00',TRUE),(4,'sabado','10:30',TRUE),(4,'sabado','11:00',TRUE),(4,'sabado','11:30',TRUE),(4,'sabado','12:00',TRUE),(4,'sabado','12:30',TRUE),(4,'sabado','13:00',TRUE),(4,'sabado','13:30',TRUE),(4,'sabado','14:00',TRUE),(4,'sabado','14:30',TRUE),(4,'sabado','15:00',TRUE),(4,'sabado','15:30',TRUE),(4,'sabado','16:00',TRUE),(4,'sabado','16:30',TRUE);

SELECT 'Banco criado com sucesso!' as status;
