-- ============================================
-- BANCO DE DADOS GOATBARBER - VERSÃO FINAL
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
    INDEX idx_tipo (tipo_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE carteiras (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT UNIQUE NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT chk_saldo_positivo CHECK (saldo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE servicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_base DECIMAL(10, 2) NOT NULL,
    duracao_minutos INT NOT NULL DEFAULT 30,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_preco_positivo CHECK (preco_base > 0)
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
    INDEX idx_barbeiro_data (barbeiro_id, data_agendamento),
    INDEX idx_cliente (cliente_id),
    INDEX idx_status (status)
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
    INDEX idx_carteira (carteira_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE configuracoes_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor VARCHAR(255) NOT NULL,
    descricao TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE categorias_produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo ENUM('produto', 'bebida') NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    destaque BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_produto(id) ON DELETE RESTRICT,
    CONSTRAINT chk_preco_produto_positivo CHECK (preco > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- DADOS INICIAIS
-- ============================================

-- Barbeiros com IDs corretos (1, 2, 3)
INSERT INTO usuarios (id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES
(1, 'Haku Santos', 'haku@goatbarber.com', '(71) 98765-4321', '12345678901', SHA2('senha123', 256), 'barbeiro', TRUE),
(2, 'Luon Yog', 'luon@goatbarber.com', '(71) 98765-4322', '12345678902', SHA2('senha123', 256), 'barbeiro', TRUE),
(3, 'Oui Uiga', 'oui@goatbarber.com', '(71) 98765-4323', '12345678903', SHA2('senha123', 256), 'barbeiro', TRUE);

-- Carteiras dos barbeiros
INSERT INTO carteiras (usuario_id, saldo) VALUES
(1, 0.00), (2, 0.00), (3, 0.00);

-- Serviços com preços corretos
INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos) VALUES
('Corte Masculino', 'Corte de cabelo masculino tradicional', 35.00, 30),
('Barba', 'Aparar e modelar barba', 25.00, 30),
('Corte + Barba (Completo)', 'Pacote completo: corte e barba', 50.00, 60);

-- Configurações
INSERT INTO configuracoes_sistema (chave, valor, descricao) VALUES
('taxa_comissao_servico', '5.0', 'Taxa de comissão sobre serviços (%)'),
('prazo_cancelamento_horas', '2', 'Prazo mínimo em horas para cancelamento sem taxa'),
('taxa_cancelamento_tardio', '10', 'Porcentagem cobrada em cancelamentos tardios (%)');

-- Categorias de produtos
INSERT INTO categorias_produto (nome, descricao, tipo) VALUES
('Cremes e Pomadas', 'Produtos para modelagem e finalização de cabelo', 'produto'),
('Gel para Cabelo', 'Géis fixadores e modeladores', 'produto'),
('Esponjas e Acessórios', 'Acessórios para cuidados capilares', 'produto'),
('Cervejas', 'Cervejas nacionais e importadas', 'bebida'),
('Refrigerantes', 'Refrigerantes e bebidas gaseificadas', 'bebida');

-- Produtos
INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo, destaque) VALUES
(1, 'Creme de cabelo (Cachop)', 'Creme modelador para cabelos cacheados', 27.99, 50, TRUE, TRUE),
(2, 'Gel para cabelo', 'Gel fixador extra forte', 15.99, 80, TRUE, TRUE),
(3, 'Esponja Nudred', 'Esponja twist para cabelos cacheados', 24.99, 30, TRUE, FALSE),
(3, 'Pata Pata', 'Escova modeladora profissional', 4.99, 25, TRUE, FALSE),
(4, 'Cerveja lata 350 ml', 'Cerveja pilsen gelada', 8.99, 100, TRUE, TRUE),
(4, 'Cerveja zero álcool', 'Cerveja sem álcool 350ml', 15.99, 60, TRUE, FALSE),
(5, 'Refrigerante lata 350 ml', 'Refrigerante cola gelado', 6.99, 120, TRUE, TRUE);

-- ============================================
-- TRIGGER PARA CRIAR CARTEIRA AUTOMATICAMENTE
-- ============================================
DELIMITER //
CREATE TRIGGER trg_criar_carteira_usuario
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT IGNORE INTO carteiras (usuario_id, saldo) VALUES (NEW.id, 0.00);
END//
DELIMITER ;

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================
SELECT 'Barbeiros cadastrados:' as info;
SELECT id, nome, tipo_usuario FROM usuarios WHERE tipo_usuario = 'barbeiro';

SELECT 'Serviços cadastrados:' as info;
SELECT id, nome, preco_base FROM servicos;

SELECT 'Configurações:' as info;
SELECT chave, valor FROM configuracoes_sistema;