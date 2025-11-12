-- ============================================
-- BANCO DE DADOS - SISTEMA DE BARBEARIA
-- (VERSÃO CORRIGIDA - COLLATION utf8mb4_unicode_ci EM TUDO)
-- ============================================
-- DROP DATABASE IF EXISTS barbearia_app;
CREATE DATABASE barbearia_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE barbearia_app;

-- ============================================
-- TABELA: usuarios
-- Armazena todos os usuários do sistema
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

-- ============================================
-- TABELA: carteiras
-- Gerencia o saldo de cada usuário
-- ============================================
CREATE TABLE carteiras (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT UNIQUE NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    CONSTRAINT chk_saldo_positivo CHECK (saldo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TABELA: servicos
-- Tipos de serviços oferecidos
-- ============================================
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

-- ============================================
-- TABELA: barbeiro_servicos
-- Serviços que cada barbeiro oferece (com preço personalizado)
-- ============================================
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

-- ============================================
-- TABELA: horarios_funcionamento
-- Horário geral de funcionamento da barbearia
-- ============================================
CREATE TABLE horarios_funcionamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dia_semana ENUM('domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado') NOT NULL UNIQUE,
    horario_abertura TIME NOT NULL DEFAULT '08:00:00',
    horario_fechamento TIME NOT NULL DEFAULT '19:00:00',
    ativo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TABELA: disponibilidade_barbeiro
-- Slots de horários disponíveis de cada barbeiro
-- ============================================
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

-- ============================================
-- TABELA: agendamentos
-- Registro de todos os agendamentos
-- ============================================
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

-- ============================================
-- TABELA: transacoes
-- Histórico de todas as movimentações financeiras
-- ============================================
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

-- ============================================
-- TABELA: avaliacoes
-- Avaliações dos serviços prestados
-- ============================================
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

-- ============================================
-- TABELA: notificacoes
-- Sistema de notificações para usuários
-- ============================================
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

-- ============================================
-- TABELA: configuracoes_sistema
-- Configurações gerais do sistema
-- ============================================
CREATE TABLE configuracoes_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor VARCHAR(255) NOT NULL,
    descricao TEXT,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TABELA: categorias_produto
-- Categorias de produtos (produtos de cabelo, bebidas, etc)
-- ============================================
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

-- ============================================
-- TABELA: produtos
-- Produtos e bebidas disponíveis
-- ============================================
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

-- ============================================
-- TABELA: vendas
-- Registro de vendas de produtos/bebidas
-- ============================================
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

-- ============================================
-- TABELA: itens_venda
-- Itens de cada venda
-- ============================================
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

-- ============================================
-- TABELA: recomendacoes
-- Sistema de recomendações de produtos/bebidas
-- ============================================
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
-- INSERÇÃO DE DADOS INICIAIS
-- ============================================

-- Horários de funcionamento padrão
INSERT INTO horarios_funcionamento (dia_semana, horario_abertura, horario_fechamento, ativo) VALUES
('domingo', '08:00:00', '19:00:00', FALSE),
('segunda', '08:00:00', '19:00:00', TRUE),
('terca', '08:00:00', '19:00:00', TRUE),
('quarta', '08:00:00', '19:00:00', TRUE),
('quinta', '08:00:00', '19:00:00', TRUE),
('sexta', '08:00:00', '19:00:00', TRUE),
('sabado', '08:00:00', '19:00:00', TRUE);

-- Serviços padrão
INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos) VALUES
('Corte Masculino', 'Corte de cabelo masculino tradicional', 35.00, 30),
('Barba', 'Aparar e modelar barba', 25.00, 30),
('Corte + Barba (Completo)', 'Pacote completo: corte e barba', 50.00, 60),
('Corte Feminino', 'Corte de cabelo feminino', 45.00, 60),
('Coloração', 'Tintura e coloração de cabelo', 80.00, 90),
('Hidratação', 'Tratamento de hidratação capilar', 60.00, 60),
('Escova', 'Escova modeladora', 40.00, 30),
('Luzes/Mechas', 'Aplicação de luzes ou mechas', 120.00, 120);

-- Configurações do sistema
INSERT INTO configuracoes_sistema (chave, valor, descricao) VALUES
('taxa_comissao_admin', '5', 'Porcentagem de comissão do admin sobre cada serviço (%)'),
('prazo_cancelamento_horas', '2', 'Prazo mínimo em horas para cancelamento sem taxa'),
('taxa_cancelamento_tardio', '10', 'Porcentagem cobrada em cancelamentos tardios (%)'),
('intervalo_agendamento_minutos', '30', 'Intervalo padrão entre agendamentos (minutos)');

-- Categorias de Produtos
INSERT INTO categorias_produto (nome, descricao, tipo) VALUES
('Cremes e Pomadas', 'Produtos para modelagem e finalização de cabelo', 'produto'),
('Gel para Cabelo', 'Géis fixadores e modeladores', 'produto'),
('Esponjas e Acessórios', 'Acessórios para cuidados capilares', 'produto'),
('Cervejas', 'Cervejas nacionais e importadas', 'bebida'),
('Refrigerantes', 'Refrigerantes e bebidas gaseificadas', 'bebida'),
('Águas', 'Águas minerais e saborizadas', 'bebida');

-- Produtos de Cabelo
INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo, destaque) VALUES
(1, 'Creme de cabelo(cachop)', 'Creme modelador para cabelos cacheados', 27.99, 50, TRUE, TRUE),
(2, 'gel para cabelo', 'Gel fixador extra forte', 15.99, 80, TRUE, TRUE),
(3, 'Esponja Nudred', 'Esponja twist para cabelos cacheados', 24.99, 30, TRUE, FALSE),
(3, 'Pata Pata', 'Escova modeladora profissional', 4.99, 25, TRUE, FALSE);

-- Bebidas
INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo, destaque) VALUES
(4, 'Cerveja lata 350 ml', 'Cerveja pilsen gelada', 8.99, 100, TRUE, TRUE),
(4, 'Cerveja zero álcool', 'Cerveja sem álcool 350ml', 15.99, 60, TRUE, FALSE),
(5, 'Refrigerante lata 350 ml', 'Refrigerante cola gelado', 6.99, 120, TRUE, TRUE),
(6, 'Água mineral 500ml', 'Água mineral natural', 3.50, 150, TRUE, FALSE);

-- Recomendações
INSERT INTO recomendacoes (titulo, descricao, produto_id, tipo, ativo, ordem) VALUES
('Produtos', 'Cremes de cabelo, gel e outros', NULL, 'produto', TRUE, 1),
('Bebidas', 'Cervejas, refrigerante e outras', NULL, 'bebida', TRUE, 2);

-- ============================================
-- INSERÇÃO DE BARBEIROS E SUAS DISPONIBILIDADES
-- ============================================

-- Criar usuários barbeiros com IDs específicos
INSERT INTO usuarios (id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES
(2, 'Haku Santos', 'haku@goatbarber.com', '(71) 98765-4321', '12345678901', SHA2('senha123', 256), 'barbeiro', TRUE),
(3, 'Luon Yog', 'luon@goatbarber.com', '(71) 98765-4322', '12345678902', SHA2('senha123', 256), 'barbeiro', TRUE),
(4, 'Oui Uiga', 'oui@goatbarber.com', '(71) 98765-4323', '12345678903', SHA2('senha123', 256), 'barbeiro', TRUE);

-- Adicionar serviços aos barbeiros
INSERT INTO barbeiro_servicos (barbeiro_id, servico_id, preco_personalizado, ativo) VALUES
-- Haku Santos (barbeiro_id = 2)
(2, 1, 35.00, TRUE),
(2, 2, 25.00, TRUE),
(2, 3, 50.00, TRUE),
(2, 4, 45.00, TRUE),
(2, 5, 80.00, TRUE),
(2, 6, 60.00, TRUE),
-- Luon Yog (barbeiro_id = 3)
(3, 1, 35.00, TRUE),
(3, 2, 25.00, TRUE),
(3, 3, 50.00, TRUE),
(3, 4, 45.00, TRUE),
(3, 5, 80.00, TRUE),
(3, 7, 40.00, TRUE),
-- Oui Uiga (barbeiro_id = 4)
(4, 1, 35.00, TRUE),
(4, 2, 25.00, TRUE),
(4, 3, 50.00, TRUE),
(4, 4, 45.00, TRUE),
(4, 6, 60.00, TRUE),
(4, 8, 120.00, TRUE);

-- ============================================
-- DISPONIBILIDADES DOS BARBEIROS
-- ============================================

-- Haku Santos - Segunda a Sexta: 08:00 a 18:00 (30 min intervalo)
INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo) VALUES
-- Segunda
(2, 'segunda', '08:00', TRUE), (2, 'segunda', '08:30', TRUE), (2, 'segunda', '09:00', TRUE), (2, 'segunda', '09:30', TRUE),
(2, 'segunda', '10:00', TRUE), (2, 'segunda', '10:30', TRUE), (2, 'segunda', '11:00', TRUE), (2, 'segunda', '11:30', TRUE),
(2, 'segunda', '12:00', TRUE), (2, 'segunda', '12:30', TRUE), (2, 'segunda', '13:00', TRUE), (2, 'segunda', '13:30', TRUE),
(2, 'segunda', '14:00', TRUE), (2, 'segunda', '14:30', TRUE), (2, 'segunda', '15:00', TRUE), (2, 'segunda', '15:30', TRUE),
(2, 'segunda', '16:00', TRUE), (2, 'segunda', '16:30', TRUE), (2, 'segunda', '17:00', TRUE), (2, 'segunda', '17:30', TRUE),
-- Terça
(2, 'terca', '08:00', TRUE), (2, 'terca', '08:30', TRUE), (2, 'terca', '09:00', TRUE), (2, 'terca', '09:30', TRUE),
(2, 'terca', '10:00', TRUE), (2, 'terca', '10:30', TRUE), (2, 'terca', '11:00', TRUE), (2, 'terca', '11:30', TRUE),
(2, 'terca', '12:00', TRUE), (2, 'terca', '12:30', TRUE), (2, 'terca', '13:00', TRUE), (2, 'terca', '13:30', TRUE),
(2, 'terca', '14:00', TRUE), (2, 'terca', '14:30', TRUE), (2, 'terca', '15:00', TRUE), (2, 'terca', '15:30', TRUE),
(2, 'terca', '16:00', TRUE), (2, 'terca', '16:30', TRUE), (2, 'terca', '17:00', TRUE), (2, 'terca', '17:30', TRUE),
-- Quarta
(2, 'quarta', '08:00', TRUE), (2, 'quarta', '08:30', TRUE), (2, 'quarta', '09:00', TRUE), (2, 'quarta', '09:30', TRUE),
(2, 'quarta', '10:00', TRUE), (2, 'quarta', '10:30', TRUE), (2, 'quarta', '11:00', TRUE), (2, 'quarta', '11:30', TRUE),
(2, 'quarta', '12:00', TRUE), (2, 'quarta', '12:30', TRUE), (2, 'quarta', '13:00', TRUE), (2, 'quarta', '13:30', TRUE),
(2, 'quarta', '14:00', TRUE), (2, 'quarta', '14:30', TRUE), (2, 'quarta', '15:00', TRUE), (2, 'quarta', '15:30', TRUE),
(2, 'quarta', '16:00', TRUE), (2, 'quarta', '16:30', TRUE), (2, 'quarta', '17:00', TRUE), (2, 'quarta', '17:30', TRUE),
-- Quinta
(2, 'quinta', '08:00', TRUE), (2, 'quinta', '08:30', TRUE), (2, 'quinta', '09:00', TRUE), (2, 'quinta', '09:30', TRUE),
(2, 'quinta', '10:00', TRUE), (2, 'quinta', '10:30', TRUE), (2, 'quinta', '11:00', TRUE), (2, 'quinta', '11:30', TRUE),
(2, 'quinta', '12:00', TRUE), (2, 'quinta', '12:30', TRUE), (2, 'quinta', '13:00', TRUE), (2, 'quinta', '13:30', TRUE),
(2, 'quinta', '14:00', TRUE), (2, 'quinta', '14:30', TRUE), (2, 'quinta', '15:00', TRUE), (2, 'quinta', '15:30', TRUE),
(2, 'quinta', '16:00', TRUE), (2, 'quinta', '16:30', TRUE), (2, 'quinta', '17:00', TRUE), (2, 'quinta', '17:30', TRUE),
-- Sexta
(2, 'sexta', '08:00', TRUE), (2, 'sexta', '08:30', TRUE), (2, 'sexta', '09:00', TRUE), (2, 'sexta', '09:30', TRUE),
(2, 'sexta', '10:00', TRUE), (2, 'sexta', '10:30', TRUE), (2, 'sexta', '11:00', TRUE), (2, 'sexta', '11:30', TRUE),
(2, 'sexta', '12:00', TRUE), (2, 'sexta', '12:30', TRUE), (2, 'sexta', '13:00', TRUE), (2, 'sexta', '13:30', TRUE),
(2, 'sexta', '14:00', TRUE), (2, 'sexta', '14:30', TRUE), (2, 'sexta', '15:00', TRUE), (2, 'sexta', '15:30', TRUE),
(2, 'sexta', '16:00', TRUE), (2, 'sexta', '16:30', TRUE), (2, 'sexta', '17:00', TRUE), (2, 'sexta', '17:30', TRUE),
-- Sábado (parcial)
(2, 'sabado', '09:00', TRUE), (2, 'sabado', '09:30', TRUE), (2, 'sabado', '10:00', TRUE), (2, 'sabado', '10:30', TRUE),
(2, 'sabado', '11:00', TRUE), (2, 'sabado', '11:30', TRUE), (2, 'sabado', '12:00', TRUE), (2, 'sabado', '12:30', TRUE),
(2, 'sabado', '13:00', TRUE), (2, 'sabado', '13:30', TRUE), (2, 'sabado', '14:00', TRUE), (2, 'sabado', '14:30', TRUE),
(2, 'sabado', '15:00', TRUE), (2, 'sabado', '15:30', TRUE), (2, 'sabado', '16:00', TRUE), (2, 'sabado', '16:30', TRUE),

-- Luon Yog - Segunda a Sexta: 08:00 a 18:00 (30 min intervalo)
INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo) VALUES
-- Segunda
(3, 'segunda', '08:00', TRUE), (3, 'segunda', '08:30', TRUE), (3, 'segunda', '09:00', TRUE), (3, 'segunda', '09:30', TRUE),
(3, 'segunda', '10:00', TRUE), (3, 'segunda', '10:30', TRUE), (3, 'segunda', '11:00', TRUE), (3, 'segunda', '11:30', TRUE),
(3, 'segunda', '12:00', TRUE), (3, 'segunda', '12:30', TRUE), (3, 'segunda', '13:00', TRUE), (3, 'segunda', '13:30', TRUE),
(3, 'segunda', '14:00', TRUE), (3, 'segunda', '14:30', TRUE), (3, 'segunda', '15:00', TRUE), (3, 'segunda', '15:30', TRUE),
(3, 'segunda', '16:00', TRUE), (3, 'segunda', '16:30', TRUE), (3, 'segunda', '17:00', TRUE), (3, 'segunda', '17:30', TRUE),
-- Terça
(3, 'terca', '08:00', TRUE), (3, 'terca', '08:30', TRUE), (3, 'terca', '09:00', TRUE), (3, 'terca', '09:30', TRUE),
(3, 'terca', '10:00', TRUE), (3, 'terca', '10:30', TRUE), (3, 'terca', '11:00', TRUE), (3, 'terca', '11:30', TRUE),
(3, 'terca', '12:00', TRUE), (3, 'terca', '12:30', TRUE), (3, 'terca', '13:00', TRUE), (3, 'terca', '13:30', TRUE),
(3, 'terca', '14:00', TRUE), (3, 'terca', '14:30', TRUE), (3, 'terca', '15:00', TRUE), (3, 'terca', '15:30', TRUE),
(3, 'terca', '16:00', TRUE), (3, 'terca', '16:30', TRUE), (3, 'terca', '17:00', TRUE), (3, 'terca', '17:30', TRUE),
-- Quarta
(3, 'quarta', '08:00', TRUE), (3, 'quarta', '08:30', TRUE), (3, 'quarta', '09:00', TRUE), (3, 'quarta', '09:30', TRUE),
(3, 'quarta', '10:00', TRUE), (3, 'quarta', '10:30', TRUE), (3, 'quarta', '11:00', TRUE), (3, 'quarta', '11:30', TRUE),
(3, 'quarta', '12:00', TRUE), (3, 'quarta', '12:30', TRUE), (3, 'quarta', '13:00', TRUE), (3, 'quarta', '13:30', TRUE),
(3, 'quarta', '14:00', TRUE), (3, 'quarta', '14:30', TRUE), (3, 'quarta', '15:00', TRUE), (3, 'quarta', '15:30', TRUE),
(3, 'quarta', '16:00', TRUE), (3, 'quarta', '16:30', TRUE), (3, 'quarta', '17:00', TRUE), (3, 'quarta', '17:30', TRUE),
-- Quinta
(3, 'quinta', '08:00', TRUE), (3, 'quinta', '08:30', TRUE), (3, 'quinta', '09:00', TRUE), (3, 'quinta', '09:30', TRUE),
(3, 'quinta', '10:00', TRUE), (3, 'quinta', '10:30', TRUE), (3, 'quinta', '11:00', TRUE), (3, 'quinta', '11:30', TRUE),
(3, 'quinta', '12:00', TRUE), (3, 'quinta', '12:30', TRUE), (3, 'quinta', '13:00', TRUE), (3, 'quinta', '13:30', TRUE),
(3, 'quinta', '14:00', TRUE), (3, 'quinta', '14:30', TRUE), (3, 'quinta', '15:00', TRUE), (3, 'quinta', '15:30', TRUE),
(3, 'quinta', '16:00', TRUE), (3, 'quinta', '16:30', TRUE), (3, 'quinta', '17:00', TRUE), (3, 'quinta', '17:30', TRUE),
-- Sexta
(3, 'sexta', '08:00', TRUE), (3, 'sexta', '08:30', TRUE), (3, 'sexta', '09:00', TRUE), (3, 'sexta', '09:30', TRUE),
(3, 'sexta', '10:00', TRUE), (3, 'sexta', '10:30', TRUE), (3, 'sexta', '11:00', TRUE), (3, 'sexta', '11:30', TRUE),
(3, 'sexta', '12:00', TRUE), (3, 'sexta', '12:30', TRUE), (3, 'sexta', '13:00', TRUE), (3, 'sexta', '13:30', TRUE),
(3, 'sexta', '14:00', TRUE), (3, 'sexta', '14:30', TRUE), (3, 'sexta', '15:00', TRUE), (3, 'sexta', '15:30', TRUE),
(3, 'sexta', '16:00', TRUE), (3, 'sexta', '16:30', TRUE), (3, 'sexta', '17:00', TRUE), (3, 'sexta', '17:30', TRUE),
-- Sábado (parcial)
(3, 'sabado', '09:00', TRUE), (3, 'sabado', '09:30', TRUE), (3, 'sabado', '10:00', TRUE), (3, 'sabado', '10:30', TRUE),
(3, 'sabado', '11:00', TRUE), (3, 'sabado', '11:30', TRUE), (3, 'sabado', '12:00', TRUE), (3, 'sabado', '12:30', TRUE),
(3, 'sabado', '13:00', TRUE), (3, 'sabado', '13:30', TRUE), (3, 'sabado', '14:00', TRUE), (3, 'sabado', '14:30', TRUE),
(3, 'sabado', '15:00', TRUE), (3, 'sabado', '15:30', TRUE), (3, 'sabado', '16:00', TRUE), (3, 'sabado', '16:30', TRUE),

-- Oui Uiga - Segunda a Sexta: 08:00 a 18:00 (30 min intervalo)
INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo) VALUES
-- Segunda
(4, 'segunda', '08:00', TRUE), (4, 'segunda', '08:30', TRUE), (4, 'segunda', '09:00', TRUE), (4, 'segunda', '09:30', TRUE),
(4, 'segunda', '10:00', TRUE), (4, 'segunda', '10:30', TRUE), (4, 'segunda', '11:00', TRUE), (4, 'segunda', '11:30', TRUE),
(4, 'segunda', '12:00', TRUE), (4, 'segunda', '12:30', TRUE), (4, 'segunda', '13:00', TRUE), (4, 'segunda', '13:30', TRUE),
(4, 'segunda', '14:00', TRUE), (4, 'segunda', '14:30', TRUE), (4, 'segunda', '15:00', TRUE), (4, 'segunda', '15:30', TRUE),
(4, 'segunda', '16:00', TRUE), (4, 'segunda', '16:30', TRUE), (4, 'segunda', '17:00', TRUE), (4, 'segunda', '17:30', TRUE),
-- Terça
(4, 'terca', '08:00', TRUE), (4, 'terca', '08:30', TRUE), (4, 'terca', '09:00', TRUE), (4, 'terca', '09:30', TRUE),
(4, 'terca', '10:00', TRUE), (4, 'terca', '10:30', TRUE), (4, 'terca', '11:00', TRUE), (4, 'terca', '11:30', TRUE),
(4, 'terca', '12:00', TRUE), (4, 'terca', '12:30', TRUE), (4, 'terca', '13:00', TRUE), (4, 'terca', '13:30', TRUE),
(4, 'terca', '14:00', TRUE), (4, 'terca', '14:30', TRUE), (4, 'terca', '15:00', TRUE), (4, 'terca', '15:30', TRUE),
(4, 'terca', '16:00', TRUE), (4, 'terca', '16:30', TRUE), (4, 'terca', '17:00', TRUE), (4, 'terca', '17:30', TRUE),
-- Quarta
(4, 'quarta', '08:00', TRUE), (4, 'quarta', '08:30', TRUE), (4, 'quarta', '09:00', TRUE), (4, 'quarta', '09:30', TRUE),
(4, 'quarta', '10:00', TRUE), (4, 'quarta', '10:30', TRUE), (4, 'quarta', '11:00', TRUE), (4, 'quarta', '11:30', TRUE),
(4, 'quarta', '12:00', TRUE), (4, 'quarta', '12:30', TRUE), (4, 'quarta', '13:00', TRUE), (4, 'quarta', '13:30', TRUE),
(4, 'quarta', '14:00', TRUE), (4, 'quarta', '14:30', TRUE), (4, 'quarta', '15:00', TRUE), (4, 'quarta', '15:30', TRUE),
(4, 'quarta', '16:00', TRUE), (4, 'quarta', '16:30', TRUE), (4, 'quarta', '17:00', TRUE), (4, 'quarta', '17:30', TRUE),
-- Quinta
(4, 'quinta', '08:00', TRUE), (4, 'quinta', '08:30', TRUE), (4, 'quinta', '09:00', TRUE), (4, 'quinta', '09:30', TRUE),
(4, 'quinta', '10:00', TRUE), (4, 'quinta', '10:30', TRUE), (4, 'quinta', '11:00', TRUE), (4, 'quinta', '11:30', TRUE),
(4, 'quinta', '12:00', TRUE), (4, 'quinta', '12:30', TRUE), (4, 'quinta', '13:00', TRUE), (4, 'quinta', '13:30', TRUE),
(4, 'quinta', '14:00', TRUE), (4, 'quinta', '14:30', TRUE), (4, 'quinta', '15:00', TRUE), (4, 'quinta', '15:30', TRUE),
(4, 'quinta', '16:00', TRUE), (4, 'quinta', '16:30', TRUE), (4, 'quinta', '17:00', TRUE), (4, 'quinta', '17:30', TRUE),
-- Sexta
(4, 'sexta', '08:00', TRUE), (4, 'sexta', '08:30', TRUE), (4, 'sexta', '09:00', TRUE), (4, 'sexta', '09:30', TRUE),
(4, 'sexta', '10:00', TRUE), (4, 'sexta', '10:30', TRUE), (4, 'sexta', '11:00', TRUE), (4, 'sexta', '11:30', TRUE),
(4, 'sexta', '12:00', TRUE), (4, 'sexta', '12:30', TRUE), (4, 'sexta', '13:00', TRUE), (4, 'sexta', '13:30', TRUE),
(4, 'sexta', '14:00', TRUE), (4, 'sexta', '14:30', TRUE), (4, 'sexta', '15:00', TRUE), (4, 'sexta', '15:30', TRUE),
(4, 'sexta', '16:00', TRUE), (4, 'sexta', '16:30', TRUE), (4, 'sexta', '17:00', TRUE), (4, 'sexta', '17:30', TRUE),
-- Sábado (parcial)
(4, 'sabado', '09:00', TRUE), (4, 'sabado', '09:30', TRUE), (4, 'sabado', '10:00', TRUE), (4, 'sabado', '10:30', TRUE),
(4, 'sabado', '11:00', TRUE), (4, 'sabado', '11:30', TRUE), (4, 'sabado', '12:00', TRUE), (4, 'sabado', '12:30', TRUE),
(4, 'sabado', '13:00', TRUE), (4, 'sabado', '13:30', TRUE), (4, 'sabado', '14:00', TRUE), (4, 'sabado', '14:30', TRUE),
(4, 'sabado', '15:00', TRUE), (4, 'sabado', '15:30', TRUE), (4, 'sabado', '16:00', TRUE), (4, 'sabado', '16:30', TRUE);

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Criar carteira automaticamente ao criar usuário
DELIMITER //
CREATE TRIGGER trg_criar_carteira_usuario
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO carteiras (usuario_id, saldo) VALUES (NEW.id, 0.00);
END//
DELIMITER ;

-- Trigger: Validar horário de agendamento dentro do funcionamento
DELIMITER //
CREATE TRIGGER trg_validar_horario_agendamento
BEFORE INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE dia_semana_agendamento VARCHAR(20);
    DECLARE horario_abre TIME;
    DECLARE horario_fecha TIME;
    DECLARE funcionamento_ativo BOOLEAN;

    -- Determinar o dia da semana
    SET dia_semana_agendamento = CASE DAYOFWEEK(NEW.data_agendamento)
        WHEN 1 THEN 'domingo'
        WHEN 2 THEN 'segunda'
        WHEN 3 THEN 'terca'
        WHEN 4 THEN 'quarta'
        WHEN 5 THEN 'quinta'
        WHEN 6 THEN 'sexta'
        WHEN 7 THEN 'sabado'
    END;

    -- Buscar horário de funcionamento
    SELECT horario_abertura, horario_fechamento, ativo
    INTO horario_abre, horario_fecha, funcionamento_ativo
    FROM horarios_funcionamento
    WHERE dia_semana = dia_semana_agendamento;

    -- Validar se está dentro do horário de funcionamento
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

-- Trigger: Validar disponibilidade do barbeiro
DELIMITER //
CREATE TRIGGER trg_validar_disponibilidade_barbeiro
BEFORE INSERT ON agendamentos
FOR EACH ROW
BEGIN
    DECLARE dia_semana_agendamento VARCHAR(20);
    DECLARE disponivel INT;

    -- Determinar o dia da semana
    SET dia_semana_agendamento = CASE DAYOFWEEK(NEW.data_agendamento)
        WHEN 1 THEN 'domingo'
        WHEN 2 THEN 'segunda'
        WHEN 3 THEN 'terca'
        WHEN 4 THEN 'quarta'
        WHEN 5 THEN 'quinta'
        WHEN 6 THEN 'sexta'
        WHEN 7 THEN 'sabado'
    END;

    -- Verificar se o barbeiro tem disponibilidade neste horário
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

    -- Verificar se já existe agendamento neste horário
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

-- Trigger: Criar notificação para barbeiro ao criar agendamento
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

-- Trigger: Criar notificação para cliente confirmando agendamento
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

-- Trigger: Registrar transação ao adicionar saldo
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

-- Trigger: Atualizar estoque após venda
DELIMITER //
CREATE TRIGGER trg_atualizar_estoque_venda
AFTER INSERT ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;

    -- Verificar se estoque ficou negativo
    IF (SELECT estoque FROM produtos WHERE id = NEW.produto_id) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estoque insuficiente para este produto';
    END IF;
END//
DELIMITER ;

-- Trigger: Restaurar estoque ao cancelar venda
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
-- STORED PROCEDURES
-- ============================================

-- Procedure: Realizar recarga na carteira
DELIMITER //
CREATE PROCEDURE sp_recarregar_carteira(
    IN p_usuario_id INT,
    IN p_valor DECIMAL(10, 2)
)
BEGIN
    DECLARE v_carteira_id INT;
    DECLARE v_saldo_anterior DECIMAL(10, 2);
    DECLARE v_saldo_novo DECIMAL(10, 2);

    -- Validações
    IF p_valor <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valor de recarga deve ser positivo';
    END IF;

    -- Buscar carteira
    SELECT id, saldo INTO v_carteira_id, v_saldo_anterior
    FROM carteiras
    WHERE usuario_id = p_usuario_id;

    IF v_carteira_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Carteira não encontrada';
    END IF;

    -- Atualizar saldo
    SET v_saldo_novo = v_saldo_anterior + p_valor;

    UPDATE carteiras
    SET saldo = v_saldo_novo
    WHERE id = v_carteira_id;

    -- Registrar transação
    INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
    VALUES (v_carteira_id, 'recarga', p_valor, v_saldo_anterior, v_saldo_novo, 'Recarga de créditos');

    SELECT 'Recarga realizada com sucesso!' AS mensagem, v_saldo_novo AS saldo_atual;
END//
DELIMITER ;

-- Procedure: Criar agendamento com pagamento
DELIMITER //
CREATE PROCEDURE sp_criar_agendamento(
    IN p_cliente_id INT,
    IN p_barbeiro_id INT,
    IN p_servico_id INT,
    IN p_data_agendamento DATE,
    IN p_horario TIME
)
BEGIN
    DECLARE v_valor_servico DECIMAL(10, 2);
    DECLARE v_taxa_comissao DECIMAL(10, 2);
    DECLARE v_valor_comissao DECIMAL(10, 2);
    DECLARE v_valor_barbeiro DECIMAL(10, 2);
    DECLARE v_saldo_cliente DECIMAL(10, 2);
    DECLARE v_carteira_cliente_id INT;
    DECLARE v_carteira_barbeiro_id INT;
    DECLARE v_agendamento_id INT;

    -- Validar se cliente e barbeiro são diferentes
    IF p_cliente_id = p_barbeiro_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente e barbeiro não podem ser a mesma pessoa';
    END IF;

    -- Validar se a data é futura
    IF p_data_agendamento < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data do agendamento deve ser futura';
    END IF;

    -- Buscar valor do serviço (verificar se barbeiro tem preço personalizado)
    SELECT COALESCE(bs.preco_personalizado, s.preco_base)
    INTO v_valor_servico
    FROM servicos s
    LEFT JOIN barbeiro_servicos bs ON bs.servico_id = s.id AND bs.barbeiro_id = p_barbeiro_id
    WHERE s.id = p_servico_id AND s.ativo = TRUE;

    IF v_valor_servico IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Serviço não encontrado ou inativo';
    END IF;

    -- Calcular comissão e valor do barbeiro
    SELECT CAST(valor AS DECIMAL(10, 2)) INTO v_taxa_comissao
    FROM configuracoes_sistema
    WHERE chave = 'taxa_comissao_admin';

    SET v_valor_comissao = v_valor_servico * (v_taxa_comissao / 100);
    SET v_valor_barbeiro = v_valor_servico - v_valor_comissao;

    -- Buscar carteiras
    SELECT id, saldo INTO v_carteira_cliente_id, v_saldo_cliente
    FROM carteiras
    WHERE usuario_id = p_cliente_id;

    SELECT id INTO v_carteira_barbeiro_id
    FROM carteiras
    WHERE usuario_id = p_barbeiro_id;

    -- Validar saldo do cliente
    IF v_saldo_cliente < v_valor_servico THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    -- Iniciar transação
    START TRANSACTION;

    -- Criar agendamento
    INSERT INTO agendamentos (
        cliente_id, barbeiro_id, servico_id, data_agendamento, horario,
        valor_servico, valor_comissao, valor_barbeiro, status
    ) VALUES (
        p_cliente_id, p_barbeiro_id, p_servico_id, p_data_agendamento, p_horario,
        v_valor_servico, v_valor_comissao, v_valor_barbeiro, 'confirmado'
    );

    SET v_agendamento_id = LAST_INSERT_ID();

    -- Debitar do cliente
    UPDATE carteiras
    SET saldo = saldo - v_valor_servico
    WHERE id = v_carteira_cliente_id;

    INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao, agendamento_id)
    VALUES (
        v_carteira_cliente_id,
        'pagamento',
        v_valor_servico,
        v_saldo_cliente,
        v_saldo_cliente - v_valor_servico,
        CONCAT('Pagamento de agendamento #', v_agendamento_id),
        v_agendamento_id
    );

    -- Creditar ao barbeiro
    UPDATE carteiras
    SET saldo = saldo + v_valor_barbeiro
    WHERE id = v_carteira_barbeiro_id;

    INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao, agendamento_id)
    SELECT 
        v_carteira_barbeiro_id,
        'recebimento',
        v_valor_barbeiro,
        saldo - v_valor_barbeiro,
        saldo,
        CONCAT('Recebimento de agendamento #', v_agendamento_id),
        v_agendamento_id
    FROM carteiras
    WHERE id = v_carteira_barbeiro_id;

    COMMIT;

    SELECT 
        'Agendamento criado com sucesso!' AS mensagem,
        v_agendamento_id AS agendamento_id,
        v_valor_servico AS valor_pago;
END//
DELIMITER ;

-- Procedure: Cancelar agendamento
DELIMITER //
CREATE PROCEDURE sp_cancelar_agendamento(
    IN p_agendamento_id INT,
    IN p_motivo TEXT
)
BEGIN
    DECLARE v_cliente_id INT;
    DECLARE v_barbeiro_id INT;
    DECLARE v_valor_servico DECIMAL(10, 2);
    DECLARE v_data_agendamento DATE;
    DECLARE v_horario TIME;
    DECLARE v_status VARCHAR(20);
    DECLARE v_horas_antecedencia INT;
    DECLARE v_prazo_minimo INT;
    DECLARE v_taxa_cancelamento DECIMAL(10, 2);
    DECLARE v_valor_estorno DECIMAL(10, 2);
    DECLARE v_valor_taxa DECIMAL(10, 2);
    DECLARE v_carteira_cliente_id INT;
    DECLARE v_carteira_barbeiro_id INT;
    DECLARE v_saldo_cliente DECIMAL(10, 2);
    DECLARE v_saldo_barbeiro DECIMAL(10, 2);
    DECLARE nome_cliente VARCHAR(100);
    DECLARE nome_servico VARCHAR(100);

    -- Buscar dados do agendamento
    SELECT 
        a.cliente_id, a.barbeiro_id, a.valor_servico, a.data_agendamento, 
        a.horario, a.status
    INTO 
        v_cliente_id, v_barbeiro_id, v_valor_servico, v_data_agendamento,
        v_horario, v_status
    FROM agendamentos a
    WHERE a.id = p_agendamento_id;

    -- Validações
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Agendamento não encontrado';
    END IF;

    IF v_status = 'cancelado' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Agendamento já foi cancelado';
    END IF;

    IF v_status = 'concluido' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível cancelar um agendamento concluído';
    END IF;

    -- Calcular horas de antecedência
    SET v_horas_antecedencia = TIMESTAMPDIFF(
        HOUR,
        NOW(),
        CONCAT(v_data_agendamento, ' ', v_horario)
    );

    -- Buscar prazo mínimo e taxa
    SELECT CAST(valor AS UNSIGNED) INTO v_prazo_minimo
    FROM configuracoes_sistema
    WHERE chave = 'prazo_cancelamento_horas';

    SELECT CAST(valor AS DECIMAL(10, 2)) INTO v_taxa_cancelamento
    FROM configuracoes_sistema
    WHERE chave = 'taxa_cancelamento_tardio';

    -- Calcular valor de estorno
    IF v_horas_antecedencia >= v_prazo_minimo THEN
        -- Estorno total
        SET v_valor_estorno = v_valor_servico;
        SET v_valor_taxa = 0;
    ELSE
        -- Estorno com taxa
        SET v_valor_taxa = v_valor_servico * (v_taxa_cancelamento / 100);
        SET v_valor_estorno = v_valor_servico - v_valor_taxa;
    END IF;

    -- Buscar carteiras e saldos
    SELECT id, saldo INTO v_carteira_cliente_id, v_saldo_cliente
    FROM carteiras WHERE usuario_id = v_cliente_id;

    SELECT id, saldo INTO v_carteira_barbeiro_id, v_saldo_barbeiro
    FROM carteiras WHERE usuario_id = v_barbeiro_id;

    -- Iniciar transação
    START TRANSACTION;

    -- Atualizar status do agendamento
    UPDATE agendamentos
    SET status = 'cancelado',
        data_cancelamento = NOW(),
        motivo_cancelamento = p_motivo
    WHERE id = p_agendamento_id;

    -- Estornar valor ao cliente
    UPDATE carteiras
    SET saldo = saldo + v_valor_estorno
    WHERE id = v_carteira_cliente_id;

    INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao, agendamento_id)
    VALUES (
        v_carteira_cliente_id,
        'estorno',
        v_valor_estorno,
        v_saldo_cliente,
        v_saldo_cliente + v_valor_estorno,
        CONCAT('Estorno do agendamento #', p_agendamento_id),
        p_agendamento_id
    );

    -- Se houver taxa, registrar
    IF v_valor_taxa > 0 THEN
        INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao, agendamento_id)
        VALUES (
            v_carteira_cliente_id,
            'taxa_cancelamento',
            v_valor_taxa,
            v_saldo_cliente + v_valor_estorno,
            v_saldo_cliente + v_valor_estorno,
            CONCAT('Taxa de cancelamento tardio - Agendamento #', p_agendamento_id),
            p_agendamento_id
        );
    END IF;

    -- Debitar do barbeiro (valor que ele havia recebido)
    UPDATE carteiras
    SET saldo = saldo - (v_valor_servico - (v_valor_servico * 0.05))
    WHERE id = v_carteira_barbeiro_id;

    INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao, agendamento_id)
    SELECT 
        v_carteira_barbeiro_id,
        'estorno',
        -(v_valor_servico - (v_valor_servico * 0.05)),
        v_saldo_barbeiro,
        saldo,
        CONCAT('Estorno por cancelamento - Agendamento #', p_agendamento_id),
        p_agendamento_id
    FROM carteiras
    WHERE id = v_carteira_barbeiro_id;

    -- Notificar barbeiro
    SELECT nome INTO nome_cliente FROM usuarios WHERE id = v_cliente_id;
    SELECT nome INTO nome_servico FROM servicos WHERE id = (SELECT servico_id FROM agendamentos WHERE id = p_agendamento_id);

    INSERT INTO notificacoes (usuario_id, tipo, titulo, mensagem, agendamento_id)
    VALUES (
        v_barbeiro_id,
        'cancelamento',
        'Agendamento Cancelado',
        CONCAT(nome_cliente, ' cancelou o agendamento de ', nome_servico, ' do dia ', DATE_FORMAT(v_data_agendamento, '%d/%m/%Y'), ' às ', TIME_FORMAT(v_horario, '%H:%i')),
        p_agendamento_id
    );

    COMMIT;

    SELECT 
        'Agendamento cancelado com sucesso!' AS mensagem,
        v_valor_estorno AS valor_estornado,
        v_valor_taxa AS taxa_cobrada;
END//
DELIMITER ;

-- Procedure: Concluir agendamento
DELIMITER //
CREATE PROCEDURE sp_concluir_agendamento(
    IN p_agendamento_id INT
)
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM agendamentos
    WHERE id = p_agendamento_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Agendamento não encontrado';
    END IF;

    IF v_status = 'concluido' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Agendamento já foi concluído';
    END IF;

    IF v_status = 'cancelado' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível concluir agendamento cancelado';
    END IF;

    UPDATE agendamentos
    SET status = 'concluido',
        data_conclusao = NOW()
    WHERE id = p_agendamento_id;

    SELECT 'Agendamento concluído com sucesso!' AS mensagem;
END//
DELIMITER ;

-- Procedure: Adicionar avaliação
DELIMITER //
CREATE PROCEDURE sp_adicionar_avaliacao(
    IN p_agendamento_id INT,
    IN p_nota INT,
    IN p_comentario TEXT
)
BEGIN
    DECLARE v_cliente_id INT;
    DECLARE v_barbeiro_id INT;
    DECLARE v_status VARCHAR(20);
    DECLARE nome_cliente VARCHAR(100);

    -- Validar nota
    IF p_nota < 1 OR p_nota > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nota deve ser entre 1 e 5';
    END IF;

    -- Buscar dados do agendamento
    SELECT cliente_id, barbeiro_id, status
    INTO v_cliente_id, v_barbeiro_id, v_status
    FROM agendamentos
    WHERE id = p_agendamento_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Agendamento não encontrado';
    END IF;

    IF v_status != 'concluido' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas agendamentos concluídos podem ser avaliados';
    END IF;

    -- Verificar se já existe avaliação
    IF EXISTS (SELECT 1 FROM avaliacoes WHERE agendamento_id = p_agendamento_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este agendamento já foi avaliado';
    END IF;

    -- Inserir avaliação
    INSERT INTO avaliacoes (agendamento_id, cliente_id, barbeiro_id, nota, comentario)
    VALUES (p_agendamento_id, v_cliente_id, v_barbeiro_id, p_nota, p_comentario);

    -- Notificar barbeiro
    SELECT nome INTO nome_cliente FROM usuarios WHERE id = v_cliente_id;

    INSERT INTO notificacoes (usuario_id, tipo, titulo, mensagem, agendamento_id)
    VALUES (
        v_barbeiro_id,
        'avaliacao',
        'Nova Avaliação!',
        CONCAT(nome_cliente, ' avaliou seu serviço com ', p_nota, ' estrelas'),
        p_agendamento_id
    );

    SELECT 'Avaliação registrada com sucesso!' AS mensagem;
END//
DELIMITER ;

-- Procedure: Adicionar disponibilidade em lote para barbeiro
DELIMITER //
CREATE PROCEDURE sp_adicionar_disponibilidade_lote(
    IN p_barbeiro_id INT,
    IN p_dia_semana VARCHAR(20),
    IN p_horario_inicio TIME,
    IN p_horario_fim TIME
)
BEGIN
    DECLARE v_horario_atual TIME;
    DECLARE v_intervalo INT;

    -- Buscar intervalo configurado
    SELECT CAST(valor AS UNSIGNED) INTO v_intervalo
    FROM configuracoes_sistema
    WHERE chave = 'intervalo_agendamento_minutos';

    SET v_horario_atual = p_horario_inicio;

    WHILE v_horario_atual < p_horario_fim DO
        INSERT INTO disponibilidade_barbeiro (barbeiro_id, dia_semana, horario, ativo)
        VALUES (p_barbeiro_id, p_dia_semana, v_horario_atual, TRUE)
        ON DUPLICATE KEY UPDATE ativo = TRUE;

        SET v_horario_atual = ADDTIME(v_horario_atual, SEC_TO_TIME(v_intervalo * 60));
    END WHILE;

    SELECT CONCAT('Disponibilidades adicionadas para ', p_dia_semana) AS mensagem;
END//
DELIMITER ;

-- Procedure: Obter média de avaliações do barbeiro
DELIMITER //
CREATE PROCEDURE sp_media_avaliacoes_barbeiro(
    IN p_barbeiro_id INT
)
BEGIN
    SELECT 
        COUNT(*) AS total_avaliacoes,
        ROUND(AVG(nota), 2) AS media_nota,
        SUM(CASE WHEN nota = 5 THEN 1 ELSE 0 END) AS avaliacoes_5_estrelas,
        SUM(CASE WHEN nota = 4 THEN 1 ELSE 0 END) AS avaliacoes_4_estrelas,
        SUM(CASE WHEN nota = 3 THEN 1 ELSE 0 END) AS avaliacoes_3_estrelas,
        SUM(CASE WHEN nota = 2 THEN 1 ELSE 0 END) AS avaliacoes_2_estrelas,
        SUM(CASE WHEN nota = 1 THEN 1 ELSE 0 END) AS avaliacoes_1_estrela
    FROM avaliacoes
    WHERE barbeiro_id = p_barbeiro_id;
END//
DELIMITER ;

-- Procedure: Relatório financeiro do barbeiro
DELIMITER //
CREATE PROCEDURE sp_relatorio_financeiro_barbeiro(
    IN p_barbeiro_id INT,
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        COUNT(*) AS total_atendimentos,
        SUM(valor_barbeiro) AS total_recebido,
        SUM(valor_comissao) AS total_comissao,
        SUM(valor_servico) AS total_faturado,
        ROUND(AVG(valor_servico), 2) AS ticket_medio
    FROM agendamentos
    WHERE barbeiro_id = p_barbeiro_id
        AND status = 'concluido'
        AND data_agendamento BETWEEN p_data_inicio AND p_data_fim;
END//
DELIMITER ;

-- Procedure: Criar venda de produtos
DELIMITER //
CREATE PROCEDURE sp_criar_venda(
    IN p_cliente_id INT,
    IN p_agendamento_id INT,
    IN p_itens JSON
)
BEGIN
    DECLARE v_venda_id INT;
    DECLARE v_valor_total DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_saldo_cliente DECIMAL(10, 2);
    DECLARE v_carteira_id INT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_total_itens INT;

    -- Contar itens
    SET v_total_itens = JSON_LENGTH(p_itens);

    -- Buscar carteira do cliente
    SELECT id, saldo INTO v_carteira_id, v_saldo_cliente
    FROM carteiras
    WHERE usuario_id = p_cliente_id;

    -- Calcular valor total
    WHILE v_idx < v_total_itens DO
        SET v_valor_total = v_valor_total + (
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].preco'))) * 
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].quantidade')))
        );
        SET v_idx = v_idx + 1;
    END WHILE;

    -- Validar saldo
    IF v_saldo_cliente < v_valor_total THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';
    END IF;

    START TRANSACTION;

    -- Criar venda
    INSERT INTO vendas (cliente_id, agendamento_id, valor_total, status, data_pagamento)
    VALUES (p_cliente_id, p_agendamento_id, v_valor_total, 'pago', NOW());

    SET v_venda_id = LAST_INSERT_ID();

    -- Inserir itens
    SET v_idx = 0;
    WHILE v_idx < v_total_itens DO
        INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario, subtotal)
        VALUES (
            v_venda_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].produto_id'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].quantidade'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].preco'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].preco'))) * 
            JSON_UNQUOTE(JSON_EXTRACT(p_itens, CONCAT('$[', v_idx, '].quantidade')))
        );
        SET v_idx = v_idx + 1;
    END WHILE;

    -- Debitar do cliente
    UPDATE carteiras
    SET saldo = saldo - v_valor_total
    WHERE id = v_carteira_id;

    INSERT INTO transacoes (carteira_id, tipo_transacao, valor, saldo_anterior, saldo_posterior, descricao)
    VALUES (
        v_carteira_id,
        'pagamento',
        v_valor_total,
        v_saldo_cliente,
        v_saldo_cliente - v_valor_total,
        CONCAT('Compra de produtos - Venda #', v_venda_id)
    );

    COMMIT;

    SELECT 'Venda realizada com sucesso!' AS mensagem, v_venda_id AS venda_id;
END//
DELIMITER ;

-- ============================================
-- VIEWS ÚTEIS
-- ============================================

-- View: Agendamentos com informações completas
CREATE VIEW vw_agendamentos_completos AS
SELECT 
    a.id,
    a.data_agendamento,
    a.horario,
    a.status,
    a.valor_servico,
    c.id AS cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    c.telefone AS cliente_telefone,
    b.id AS barbeiro_id,
    b.nome AS barbeiro_nome,
    b.email AS barbeiro_email,
    s.id AS servico_id,
    s.nome AS servico_nome,
    s.duracao_minutos,
    av.nota AS avaliacao_nota,
    av.comentario AS avaliacao_comentario,
    a.data_criacao,
    a.data_conclusao,
    a.data_cancelamento
FROM agendamentos a
INNER JOIN usuarios c ON a.cliente_id = c.id
INNER JOIN usuarios b ON a.barbeiro_id = b.id
INNER JOIN servicos s ON a.servico_id = s.id
LEFT JOIN avaliacoes av ON av.agendamento_id = a.id;

-- View: Barbeiros com estatísticas
CREATE VIEW vw_barbeiros_estatisticas AS
SELECT 
    u.id,
    u.nome,
    u.email,
    u.telefone,
    c.saldo,
    COUNT(DISTINCT a.id) AS total_atendimentos,
    COUNT(DISTINCT CASE WHEN a.status = 'concluido' THEN a.id END) AS atendimentos_concluidos,
    ROUND(AVG(av.nota), 2) AS media_avaliacoes,
    COUNT(DISTINCT av.id) AS total_avaliacoes
FROM usuarios u
INNER JOIN carteiras c ON c.usuario_id = u.id
LEFT JOIN agendamentos a ON a.barbeiro_id = u.id
LEFT JOIN avaliacoes av ON av.barbeiro_id = u.id
WHERE u.tipo_usuario = 'barbeiro' AND u.ativo = TRUE
GROUP BY u.id, u.nome, u.email, u.telefone, c.saldo;

-- View: Horários disponíveis por barbeiro
CREATE VIEW vw_disponibilidade_barbeiros AS
SELECT 
    u.id AS barbeiro_id,
    u.nome AS barbeiro_nome,
    d.dia_semana,
    d.horario,
    d.ativo
FROM usuarios u
INNER JOIN disponibilidade_barbeiro d ON d.barbeiro_id = u.id
WHERE u.tipo_usuario = 'barbeiro' AND u.ativo = TRUE
ORDER BY u.nome, d.dia_semana, d.horario;

-- View: Produtos com categoria
CREATE VIEW vw_produtos_completo AS
SELECT 
    p.id,
    p.nome,
    p.descricao,
    p.preco,
    p.estoque,
    p.imagem_url,
    p.ativo,
    p.destaque,
    c.nome AS categoria_nome,
    c.tipo AS categoria_tipo
FROM produtos p
INNER JOIN categorias_produto c ON c.id = p.categoria_id;

-- View: Vendas com detalhes
CREATE VIEW vw_vendas_completas AS
SELECT 
    v.id,
    v.valor_total,
    v.status,
    v.data_venda,
    u.nome AS cliente_nome,
    u.email AS cliente_email,
    COUNT(iv.id) AS total_itens
FROM vendas v
INNER JOIN usuarios u ON u.id = v.cliente_id
LEFT JOIN itens_venda iv ON iv.venda_id = v.id
GROUP BY v.id, v.valor_total, v.status, v.data_venda, u.nome, u.email;

-- ============================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- ============================================

CREATE INDEX idx_agendamentos_data_status ON agendamentos(data_agendamento, status);
CREATE INDEX idx_agendamentos_barbeiro_data ON agendamentos(barbeiro_id, data_agendamento);
CREATE INDEX idx_transacoes_carteira_data ON transacoes(carteira_id, data_transacao);
CREATE INDEX idx_notificacoes_usuario_lida ON notificacoes(usuario_id, lida);

-- =================================================================================
-- FIM DO SCRIPT - BANCO COMPLETO COM COLLATION utf8mb4_unicode_ci
-- =================================================================================
