-- Inserir serviços padrão na tabela servicos
-- Primeiro, limpar serviços existentes se necessário
-- DELETE FROM servicos WHERE id IN (1,2,3,4,5,6,7,8);

-- Serviços padrão
INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos) VALUES
('Corte Masculino', 'Corte de cabelo masculino tradicional', 35.00, 30),
('Barba', 'Aparar e modelar barba', 25.00, 30),
('Corte + Barba (Completo)', 'Pacote completo: corte e barba', 50.00, 60),
('Corte Feminino', 'Corte de cabelo feminino', 45.00, 60),
('Coloração', 'Tintura e coloração de cabelo', 80.00, 90),
('Hidratação', 'Tratamento de hidratação capilar', 60.00, 60),
('Escova', 'Escova modeladora', 40.00, 30),
('Luzes/Mechas', 'Aplicação de luzes ou mechas', 120.00, 120)
ON DUPLICATE KEY UPDATE
nome = VALUES(nome),
descricao = VALUES(descricao),
preco_base = VALUES(preco_base),
duracao_minutos = VALUES(duracao_minutos);