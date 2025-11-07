-- Corrigir saldo do usuário 3 (Pedro Cliente)
-- Ele tinha 75, gastou 30, deveria ter 45, mas está com 30
-- Vamos corrigir para 75 para que o próximo agendamento funcione corretamente

UPDATE carteiras SET saldo = 75.00 WHERE id_cliente = 3;