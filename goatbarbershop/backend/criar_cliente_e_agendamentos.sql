-- Primeiro, verificar usuários existentes
SELECT id, nome, tipo_usuario FROM usuarios;

-- Criar um cliente de teste
INSERT INTO usuarios (nome, cpf, email, telefone, senha_hash, tipo_usuario, data_cadastro, ativo) VALUES
('João Silva', '12345678901', 'joao@teste.com', '(11) 99999-9999', '$2a$10$kJHW2teH3cIijGqzXIdTS.7G8mGIzCgVD1nhrscPhwPBpPB2SA4Km', 'cliente', NOW(), 1);

-- Criar carteira para o cliente
INSERT INTO carteiras (usuario_id, saldo) VALUES
(LAST_INSERT_ID(), 1000.00);

-- Obter o ID do cliente criado
SET @cliente_id = LAST_INSERT_ID();

-- Inserir agendamentos de teste usando o ID do cliente criado
INSERT INTO agendamentos (cliente_id, barbeiro_id, servico_id, data_agendamento, horario, valor_servico, status, data_criacao) VALUES
(@cliente_id, 1, 1, CURDATE(), '10:00', 35.00, 'agendado', NOW()),
(@cliente_id, 1, 2, CURDATE(), '14:00', 25.00, 'agendado', NOW()),
(@cliente_id, 2, 3, CURDATE(), '16:00', 50.00, 'agendado', NOW());

-- Verificar se foram criados
SELECT a.*, u.nome as cliente_nome, b.nome as barbeiro_nome, s.nome as servico_nome 
FROM agendamentos a
JOIN usuarios u ON a.cliente_id = u.id
JOIN usuarios b ON a.barbeiro_id = b.id  
JOIN servicos s ON a.servico_id = s.id
WHERE a.data_agendamento = CURDATE();