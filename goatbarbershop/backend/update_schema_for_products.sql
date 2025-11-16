-- =================================================================
-- SCRIPT DE ATUALIZAÇÃO DO BANCO DE DADOS
-- Adiciona suporte para produtos em agendamentos
-- =================================================================

-- 1. Adicionar colunas 'valor_produtos' e 'valor_total' na tabela 'agendamentos'
-- Isso permitirá armazenar o custo dos produtos e o custo geral do agendamento.
ALTER TABLE agendamentos
ADD COLUMN valor_produtos DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Valor total dos produtos adicionados ao agendamento' AFTER valor_servico,
ADD COLUMN valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Valor total (serviço + produtos)' AFTER valor_produtos;

-- Atualizar o valor_total para os registros existentes, que não tinham produtos.
UPDATE agendamentos SET valor_total = valor_servico WHERE id > 0;

-- =================================================================

-- 2. Criar a tabela 'agendamento_produtos'
-- Esta é uma tabela de junção para criar uma relação muitos-para-muitos
-- entre agendamentos e produtos.
CREATE TABLE agendamento_produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agendamento_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10, 2) NOT NULL COMMENT 'Preço do produto no momento da compra',
    subtotal DECIMAL(10, 2) NOT NULL COMMENT 'Subtotal (quantidade * preco_unitario)',
    
    FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT,
    
    UNIQUE KEY unique_agendamento_produto (agendamento_id, produto_id),
    
    INDEX idx_agendamento (agendamento_id),
    INDEX idx_produto (produto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Produtos associados a um agendamento específico';

-- =================================================================
-- FIM DO SCRIPT
-- =================================================================
