-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS app_barbearia;
USE app_barbearia;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    cpf VARCHAR(14),
    senha VARCHAR(255),
    papel ENUM('cliente', 'barbeiro', 'admin') DEFAULT 'cliente',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela de carteiras
CREATE TABLE IF NOT EXISTS carteiras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    saldo DECIMAL(10,2) DEFAULT 0.00,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabela de transações
CREATE TABLE IF NOT EXISTS transacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_carteira INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    tipo ENUM('credito', 'debito') NOT NULL,
    descricao VARCHAR(255),
    id_agendamento INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_carteira) REFERENCES carteiras(id) ON DELETE CASCADE
);

-- Tabela de serviços
CREATE TABLE IF NOT EXISTS servicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_barbeiro INT,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    duracao_minutos INT NOT NULL,
    preco_creditos DECIMAL(10,2) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- Tabela de agendamentos
CREATE TABLE IF NOT EXISTS agendamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_barbeiro INT,
    id_servico INT NOT NULL,
    data_hora_agendamento DATETIME NOT NULL,
    status ENUM('confirmado', 'cancelado', 'concluido') DEFAULT 'confirmado',
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (id_barbeiro) REFERENCES usuarios(id) ON DELETE SET NULL,
    FOREIGN KEY (id_servico) REFERENCES servicos(id) ON DELETE CASCADE
);

-- Banco criado com sucesso