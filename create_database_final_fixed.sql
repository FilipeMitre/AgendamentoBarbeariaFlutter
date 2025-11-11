-- ============================================
-- BANCO DE DADOS - APP BARBEARIA
-- Sistema completo com carteiras de barbeiros
-- VERSÃO CORRIGIDA - Carteiras funcionais
-- ============================================

SET time_zone = '-03:00';

CREATE DATABASE IF NOT EXISTS app_barbearia;
USE app_barbearia;

-- ============================================
-- TABELAS PRINCIPAIS
-- ============================================

CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
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
    id_usuario INT NOT NULL,
    tipo_usuario ENUM('cliente', 'barbeiro') NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    receita_servicos DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS transacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_carteira INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    tipo ENUM('credito', 'debito') NOT NULL,
    categoria ENUM('deposito', 'receita_servico', 'pagamento_servico', 'saque') NOT NULL,
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
(1, 'Segunda-feira', '09:00:00', '18:00:00'),
(1, 'Terça-feira', '09:00:00', '18:00:00'),
(1, 'Quarta-feira', '09:00:00', '18:00:00'),
(1, 'Quinta-feira', '09:00:00', '18:00:00'),
(1, 'Sexta-feira', '09:00:00', '18:00:00'),
(1, 'Sábado', '08:00:00', '17:00:00'),
(2, 'Segunda-feira', '10:00:00', '19:00:00'),
(2, 'Terça-feira', '10:00:00', '19:00:00'),
(2, 'Quarta-feira', '10:00:00', '19:00:00'),
(2, 'Quinta-feira', '10:00:00', '19:00:00'),
(2, 'Sexta-feira', '10:00:00', '19:00:00'),
(2, 'Sábado', '09:00:00', '18:00:00');

-- Carteiras dos clientes
INSERT INTO carteiras (id_usuario, tipo_usuario, saldo) VALUES
(3, 'cliente', 100.00),
(4, 'cliente', 50.00);

-- Carteiras dos barbeiros
INSERT INTO carteiras (id_usuario, tipo_usuario, saldo, receita_servicos) VALUES
(1, 'barbeiro', 0.00, 0.00),
(2, 'barbeiro', 0.00, 0.00);

INSERT INTO transacoes (id_carteira, valor, tipo, categoria, descricao, id_agendamento) VALUES
(1, 50.00, 'credito', 'deposito', 'Depósito inicial', NULL);

-- Agendamentos
INSERT INTO agendamentos (id_cliente, id_barbeiro, id_servico, data_hora_agendamento, status)
VALUES (3, 1, 1, '2025-09-25 10:00:00', 'confirmado'),
       (4, 2, 4, '2025-09-26 15:30:00', 'confirmado'),
       (3, 1, 2, '2025-09-24 11:00:00', 'concluido');

-- ============================================
-- STORED PROCEDURES PARA CARTEIRA DO BARBEIRO
-- ============================================

DELIMITER //

CREATE PROCEDURE DepositoBarbeiro(
    IN p_id_barbeiro INT,
    IN p_valor DECIMAL(10,2),
    IN p_descricao VARCHAR(255)
)
BEGIN
    DECLARE v_id_carteira INT;
    
    SELECT id INTO v_id_carteira 
    FROM carteiras 
    WHERE id_usuario = p_id_barbeiro AND tipo_usuario = 'barbeiro';
    
    IF v_id_carteira IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carteira do barbeiro não encontrada';
    END IF;
    
    UPDATE carteiras 
    SET saldo = saldo + p_valor 
    WHERE id = v_id_carteira;
    
    INSERT INTO transacoes (id_carteira, valor, tipo, categoria, descricao)
    VALUES (v_id_carteira, p_valor, 'credito', 'deposito', p_descricao);
END//

CREATE PROCEDURE ReceitaServicoBarbeiro(
    IN p_id_agendamento INT
)
BEGIN
    DECLARE v_id_barbeiro INT;
    DECLARE v_id_carteira INT;
    DECLARE v_valor_servico DECIMAL(10,2);
    DECLARE v_nome_servico VARCHAR(255);
    
    SELECT a.id_barbeiro, s.preco_creditos, s.nome
    INTO v_id_barbeiro, v_valor_servico, v_nome_servico
    FROM agendamentos a
    JOIN servicos s ON a.id_servico = s.id
    WHERE a.id = p_id_agendamento AND a.status = 'concluido';
    
    IF v_id_barbeiro IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Agendamento não encontrado ou não concluído';
    END IF;
    
    SELECT id INTO v_id_carteira 
    FROM carteiras 
    WHERE id_usuario = v_id_barbeiro AND tipo_usuario = 'barbeiro';
    
    UPDATE carteiras 
    SET receita_servicos = receita_servicos + v_valor_servico 
    WHERE id = v_id_carteira;
    
    INSERT INTO transacoes (id_carteira, valor, tipo, categoria, descricao, id_agendamento)
    VALUES (v_id_carteira, v_valor_servico, 'credito', 'receita_servico', 
            CONCAT('Receita do serviço: ', v_nome_servico), p_id_agendamento);
END//

CREATE PROCEDURE SaqueBarbeiro(
    IN p_id_barbeiro INT,
    IN p_valor DECIMAL(10,2),
    IN p_tipo_saque ENUM('saldo', 'receita', 'ambos'),
    IN p_descricao VARCHAR(255)
)
BEGIN
    DECLARE v_id_carteira INT;
    DECLARE v_saldo_atual DECIMAL(10,2);
    DECLARE v_receita_atual DECIMAL(10,2);
    DECLARE v_valor_saldo DECIMAL(10,2) DEFAULT 0;
    DECLARE v_valor_receita DECIMAL(10,2) DEFAULT 0;
    
    SELECT id, saldo, receita_servicos 
    INTO v_id_carteira, v_saldo_atual, v_receita_atual
    FROM carteiras 
    WHERE id_usuario = p_id_barbeiro AND tipo_usuario = 'barbeiro';
    
    IF v_id_carteira IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Carteira do barbeiro não encontrada';
    END IF;
    
    IF p_tipo_saque = 'saldo' THEN
        IF v_saldo_atual < p_valor THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
        END IF;
        SET v_valor_saldo = p_valor;
    ELSEIF p_tipo_saque = 'receita' THEN
        IF v_receita_atual < p_valor THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receita insuficiente';
        END IF;
        SET v_valor_receita = p_valor;
    ELSEIF p_tipo_saque = 'ambos' THEN
        IF (v_saldo_atual + v_receita_atual) < p_valor THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fundos insuficientes';
        END IF;
        
        IF v_receita_atual >= p_valor THEN
            SET v_valor_receita = p_valor;
        ELSE
            SET v_valor_receita = v_receita_atual;
            SET v_valor_saldo = p_valor - v_receita_atual;
        END IF;
    END IF;
    
    UPDATE carteiras 
    SET saldo = saldo - v_valor_saldo,
        receita_servicos = receita_servicos - v_valor_receita
    WHERE id = v_id_carteira;
    
    INSERT INTO transacoes (id_carteira, valor, tipo, categoria, descricao)
    VALUES (v_id_carteira, p_valor, 'debito', 'saque', p_descricao);
END//

CREATE PROCEDURE ConsultarCarteiraBarbeiro(
    IN p_id_barbeiro INT
)
BEGIN
    SELECT 
        c.saldo,
        c.receita_servicos,
        (c.saldo + c.receita_servicos) as total_disponivel,
        u.nome as nome_barbeiro
    FROM carteiras c
    JOIN usuarios u ON c.id_usuario = u.id
    WHERE c.id_usuario = p_id_barbeiro AND c.tipo_usuario = 'barbeiro';
END//

DELIMITER ;

-- ============================================
-- TRIGGER PARA RECEITA AUTOMÁTICA
-- ============================================

DELIMITER //

CREATE TRIGGER tr_receita_servico_concluido
AFTER UPDATE ON agendamentos
FOR EACH ROW
BEGIN
    IF NEW.status = 'concluido' AND OLD.status != 'concluido' THEN
        CALL ReceitaServicoBarbeiro(NEW.id);
    END IF;
END//

DELIMITER ;

-- ============================================
-- DADOS DE TESTE
-- ============================================

CALL DepositoBarbeiro(1, 150.00, 'Depósito inicial - João');
CALL DepositoBarbeiro(2, 200.00, 'Depósito inicial - Maria');

-- ============================================
-- VIEWS PARA RELATÓRIOS
-- ============================================

CREATE VIEW vw_receitas_barbeiros AS
SELECT 
    u.id,
    u.nome as barbeiro,
    c.saldo,
    c.receita_servicos,
    (c.saldo + c.receita_servicos) as total_carteira,
    COUNT(DISTINCT a.id) as total_servicos_concluidos
FROM usuarios u
JOIN carteiras c ON u.id = c.id_usuario AND c.tipo_usuario = 'barbeiro'
LEFT JOIN agendamentos a ON u.id = a.id_barbeiro AND a.status = 'concluido'
WHERE u.papel = 'barbeiro'
GROUP BY u.id, u.nome, c.saldo, c.receita_servicos;

CREATE VIEW vw_saldo_clientes AS
SELECT
    u.nome AS nome_cliente,
    c.saldo
FROM
    carteiras c
JOIN
    usuarios u ON c.id_usuario = u.id
WHERE c.tipo_usuario = 'cliente';

SELECT 'Sistema de carteiras dos barbeiros implementado com sucesso!' as status;