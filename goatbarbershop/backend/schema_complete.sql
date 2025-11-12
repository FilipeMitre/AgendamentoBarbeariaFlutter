-- ============================================
-- BANCO DE DADOS - SISTEMA DE BARBEARIA
-- (VERSÃO FINAL - SCRIPT COMPLETO COM COLLATION CORRIGIDA)
-- ============================================
-- IMPORTANTE: Execute este script para RESETAR e criar o banco com collation corrigida
-- Descomente a linha abaixo se quiser deletar o banco anterior
-- DROP DATABASE IF EXISTS barbearia_app;

CREATE DATABASE IF NOT EXISTS barbearia_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE barbearia_app;

-- ============================================
-- TABELA: usuarios
-- Armazena todos os usuários do sistema
-- ============================================
CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL COLLATE utf8mb4_unicode_ci,
    email VARCHAR(100) UNIQUE NOT NULL COLLATE utf8mb4_unicode_ci,
    telefone VARCHAR(20) NOT NULL COLLATE utf8mb4_unicode_ci,
    cpf VARCHAR(14) UNIQUE NULL COLLATE utf8mb4_unicode_ci,
    senha_hash VARCHAR(255) NOT NULL COLLATE utf8mb4_unicode_ci,
    tipo_usuario ENUM('cliente', 'barbeiro', 'admin') DEFAULT 'cliente' COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS carteiras (
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
CREATE TABLE IF NOT EXISTS servicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL COLLATE utf8mb4_unicode_ci,
    descricao TEXT COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS barbeiro_servicos (
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
CREATE TABLE IF NOT EXISTS horarios_funcionamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dia_semana ENUM('domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado') NOT NULL UNIQUE COLLATE utf8mb4_unicode_ci,
    horario_abertura TIME NOT NULL DEFAULT '08:00:00',
    horario_fechamento TIME NOT NULL DEFAULT '19:00:00',
    ativo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TABELA: disponibilidade_barbeiro
-- Slots de horários disponíveis de cada barbeiro
-- ============================================
CREATE TABLE IF NOT EXISTS disponibilidade_barbeiro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    barbeiro_id INT NOT NULL,
    dia_semana ENUM('domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado') NOT NULL COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS agendamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    barbeiro_id INT NOT NULL,
    servico_id INT NOT NULL,
    data_agendamento DATE NOT NULL,
    horario TIME NOT NULL,
    valor_servico DECIMAL(10, 2) NOT NULL,
    valor_comissao DECIMAL(10, 2) NOT NULL,
    valor_barbeiro DECIMAL(10, 2) NOT NULL,
    status ENUM('pendente', 'confirmado', 'concluido', 'cancelado') DEFAULT 'confirmado' COLLATE utf8mb4_unicode_ci,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_conclusao TIMESTAMP NULL,
    data_cancelamento TIMESTAMP NULL,
    motivo_cancelamento TEXT NULL COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS transacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    carteira_id INT NOT NULL,
    tipo_transacao ENUM('recarga', 'pagamento', 'recebimento', 'estorno', 'taxa_cancelamento', 'comissao') NOT NULL COLLATE utf8mb4_unicode_ci,
    valor DECIMAL(10, 2) NOT NULL,
    saldo_anterior DECIMAL(10, 2) NOT NULL,
    saldo_posterior DECIMAL(10, 2) NOT NULL,
    descricao TEXT COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS avaliacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agendamento_id INT UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    barbeiro_id INT NOT NULL,
    nota INT NOT NULL,
    comentario TEXT NULL COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS notificacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    tipo ENUM('novo_agendamento', 'cancelamento', 'confirmacao', 'lembrete', 'avaliacao', 'sistema') NOT NULL COLLATE utf8mb4_unicode_ci,
    titulo VARCHAR(200) NOT NULL COLLATE utf8mb4_unicode_ci,
    mensagem TEXT NOT NULL COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS configuracoes_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave VARCHAR(100) UNIQUE NOT NULL COLLATE utf8mb4_unicode_ci,
    valor VARCHAR(255) NOT NULL COLLATE utf8mb4_unicode_ci,
    descricao TEXT COLLATE utf8mb4_unicode_ci,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TABELA: categorias_produto
-- Categorias de produtos (produtos de cabelo, bebidas, etc)
-- ============================================
CREATE TABLE IF NOT EXISTS categorias_produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL COLLATE utf8mb4_unicode_ci,
    descricao TEXT COLLATE utf8mb4_unicode_ci,
    tipo ENUM('produto', 'bebida') NOT NULL COLLATE utf8mb4_unicode_ci,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tipo (tipo),
    INDEX idx_ativo (ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- TABELA: produtos
-- Produtos e bebidas disponíveis
-- ============================================
CREATE TABLE IF NOT EXISTS produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT NOT NULL,
    nome VARCHAR(200) NOT NULL COLLATE utf8mb4_unicode_ci,
    descricao TEXT COLLATE utf8mb4_unicode_ci,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT DEFAULT 0,
    imagem_url VARCHAR(500) COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS vendas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    agendamento_id INT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    status ENUM('pendente', 'pago', 'cancelado') DEFAULT 'pendente' COLLATE utf8mb4_unicode_ci,
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
CREATE TABLE IF NOT EXISTS itens_venda (
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
CREATE TABLE IF NOT EXISTS recomendacoes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL COLLATE utf8mb4_unicode_ci,
    descricao TEXT COLLATE utf8mb4_unicode_ci,
    produto_id INT NULL,
    tipo ENUM('produto', 'bebida', 'combo') NOT NULL COLLATE utf8mb4_unicode_ci,
    ativo BOOLEAN DEFAULT TRUE,
    ordem INT DEFAULT 0,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE SET NULL,
    INDEX idx_tipo (tipo),
    INDEX idx_ativo (ativo),
    INDEX idx_ordem (ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- DADOS INICIAIS
-- ============================================

DELETE FROM horarios_funcionamento;
DELETE FROM servicos;
DELETE FROM configuracoes_sistema;
DELETE FROM categorias_produto;

INSERT INTO horarios_funcionamento (dia_semana, horario_abertura, horario_fechamento, ativo) VALUES
('domingo', '08:00:00', '19:00:00', FALSE),
('segunda', '08:00:00', '19:00:00', TRUE),
('terca', '08:00:00', '19:00:00', TRUE),
('quarta', '08:00:00', '19:00:00', TRUE),
('quinta', '08:00:00', '19:00:00', TRUE),
('sexta', '08:00:00', '19:00:00', TRUE),
('sabado', '08:00:00', '19:00:00', TRUE)
ON DUPLICATE KEY UPDATE ativo=VALUES(ativo);

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
(1, 'Creme de cabelo (Cachop)', 'Creme modelador para cabelos cacheados', 27.99, 50, TRUE, TRUE),
(2, 'Gel para cabelo', 'Gel fixador extra forte', 15.99, 80, TRUE, TRUE),
(3, 'Esponja Nudred', 'Esponja twist para cabelos cacheados', 24.99, 30, TRUE, FALSE),
(3, 'Pata Pata', 'Escova modeladora profissional', 4.99, 25, TRUE, FALSE),
(4, 'Cerveja lata 350 ml', 'Cerveja pilsen gelada', 8.99, 100, TRUE, TRUE),
(4, 'Cerveja zero álcool', 'Cerveja sem álcool 350ml', 15.99, 60, TRUE, FALSE),
(5, 'Refrigerante lata 350 ml', 'Refrigerante cola gelado', 6.99, 120, TRUE, TRUE),
(6, 'Água mineral 500ml', 'Água mineral natural', 3.50, 150, TRUE, FALSE);

INSERT INTO recomendacoes (titulo, descricao, produto_id, tipo, ativo, ordem) VALUES
('Produtos', 'Cremes de cabelo, gel e outros', NULL, 'produto', TRUE, 1),
('Bebidas', 'Cervejas, refrigerante e outras', NULL, 'bebida', TRUE, 2);

-- =================================================================================
-- FIM DO SCRIPT - BANCO PRONTO PARA USO COM COLLATION utf8mb4_unicode_ci
-- =================================================================================
