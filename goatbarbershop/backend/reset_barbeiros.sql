-- ============================================
-- RESET SIMPLES - APENAS PARA RECRIAR OS BARBEIROS
-- ============================================

USE barbearia_app;

-- Limpar dados antigos (se houver)
DELETE FROM disponibilidade_barbeiro WHERE barbeiro_id IN (2, 3, 4);
DELETE FROM barbeiro_servicos WHERE barbeiro_id IN (2, 3, 4);
DELETE FROM agendamentos WHERE barbeiro_id IN (2, 3, 4) OR cliente_id IN (2, 3, 4);
DELETE FROM avaliacoes WHERE barbeiro_id IN (2, 3, 4) OR cliente_id IN (2, 3, 4);
DELETE FROM transacoes WHERE carteira_id IN (SELECT id FROM carteiras WHERE usuario_id IN (2, 3, 4));
DELETE FROM carteiras WHERE usuario_id IN (2, 3, 4);
DELETE FROM notificacoes WHERE usuario_id IN (2, 3, 4);
DELETE FROM usuarios WHERE id IN (2, 3, 4);

-- Recriar barbeiros com IDs específicos
INSERT INTO usuarios (id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES
(2, 'Haku Santos', 'haku@goatbarber.com', '(71) 98765-4321', '12345678901', SHA2('senha123', 256), 'barbeiro', TRUE),
(3, 'Luon Yog', 'luon@goatbarber.com', '(71) 98765-4322', '12345678902', SHA2('senha123', 256), 'barbeiro', TRUE),
(4, 'Oui Uiga', 'oui@goatbarber.com', '(71) 98765-4323', '12345678903', SHA2('senha123', 256), 'barbeiro', TRUE);

-- Adicionar serviços aos barbeiros
INSERT INTO barbeiro_servicos (barbeiro_id, servico_id, preco_personalizado, ativo) VALUES
-- Haku Santos
(2, 1, 35.00, TRUE),
(2, 2, 25.00, TRUE),
(2, 3, 50.00, TRUE),
(2, 4, 45.00, TRUE),
(2, 5, 80.00, TRUE),
(2, 6, 60.00, TRUE),
-- Luon Yog
(3, 1, 35.00, TRUE),
(3, 2, 25.00, TRUE),
(3, 3, 50.00, TRUE),
(3, 4, 45.00, TRUE),
(3, 5, 80.00, TRUE),
(3, 7, 40.00, TRUE),
-- Oui Uiga
(4, 1, 35.00, TRUE),
(4, 2, 25.00, TRUE),
(4, 3, 50.00, TRUE),
(4, 4, 45.00, TRUE),
(4, 6, 60.00, TRUE),
(4, 8, 120.00, TRUE);

-- Adicionar disponibilidades dos 3 barbeiros
-- Haku Santos (Segunda a Sábado, 08:00 a 18:00)
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
-- Sábado
(2, 'sabado', '09:00', TRUE), (2, 'sabado', '09:30', TRUE), (2, 'sabado', '10:00', TRUE), (2, 'sabado', '10:30', TRUE),
(2, 'sabado', '11:00', TRUE), (2, 'sabado', '11:30', TRUE), (2, 'sabado', '12:00', TRUE), (2, 'sabado', '12:30', TRUE),
(2, 'sabado', '13:00', TRUE), (2, 'sabado', '13:30', TRUE), (2, 'sabado', '14:00', TRUE), (2, 'sabado', '14:30', TRUE),
(2, 'sabado', '15:00', TRUE), (2, 'sabado', '15:30', TRUE), (2, 'sabado', '16:00', TRUE), (2, 'sabado', '16:30', TRUE),

-- Luon Yog (Segunda a Sábado, 08:00 a 18:00)
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
-- Sábado
(3, 'sabado', '09:00', TRUE), (3, 'sabado', '09:30', TRUE), (3, 'sabado', '10:00', TRUE), (3, 'sabado', '10:30', TRUE),
(3, 'sabado', '11:00', TRUE), (3, 'sabado', '11:30', TRUE), (3, 'sabado', '12:00', TRUE), (3, 'sabado', '12:30', TRUE),
(3, 'sabado', '13:00', TRUE), (3, 'sabado', '13:30', TRUE), (3, 'sabado', '14:00', TRUE), (3, 'sabado', '14:30', TRUE),
(3, 'sabado', '15:00', TRUE), (3, 'sabado', '15:30', TRUE), (3, 'sabado', '16:00', TRUE), (3, 'sabado', '16:30', TRUE),

-- Oui Uiga (Segunda a Sábado, 08:00 a 18:00)
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
-- Sábado
(4, 'sabado', '09:00', TRUE), (4, 'sabado', '09:30', TRUE), (4, 'sabado', '10:00', TRUE), (4, 'sabado', '10:30', TRUE),
(4, 'sabado', '11:00', TRUE), (4, 'sabado', '11:30', TRUE), (4, 'sabado', '12:00', TRUE), (4, 'sabado', '12:30', TRUE),
(4, 'sabado', '13:00', TRUE), (4, 'sabado', '13:30', TRUE), (4, 'sabado', '14:00', TRUE), (4, 'sabado', '14:30', TRUE),
(4, 'sabado', '15:00', TRUE), (4, 'sabado', '15:30', TRUE), (4, 'sabado', '16:00', TRUE), (4, 'sabado', '16:30', TRUE);

-- Verificar dados inseridos
SELECT COUNT(*) as total_usuarios FROM usuarios;
SELECT COUNT(*) as total_servicos FROM barbeiro_servicos;
SELECT COUNT(*) as total_disponibilidades FROM disponibilidade_barbeiro;
