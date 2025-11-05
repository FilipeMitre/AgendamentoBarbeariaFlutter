# Migração SQLite para MySQL

## Resumo das Alterações

Este documento descreve as alterações realizadas para migrar o sistema de SQLite para MySQL, utilizando o banco de dados fornecido.

## Arquivos Modificados

### 1. pubspec.yaml
- **Removido**: `sqflite: ^2.3.0` e `path: ^1.8.3`
- **Adicionado**: `mysql1: ^0.20.0`

### 2. lib/config/database_config.dart (NOVO)
- Configuração centralizada para conexão MySQL
- Host: localhost
- Porta: 3306
- Usuário: root
- Senha: (vazia)
- Database: app_barbearia

### 3. lib/database/database_helper.dart
- Substituída implementação SQLite por MySQL
- Utiliza ConnectionSettings do mysql1
- Conecta ao banco app_barbearia existente

### 4. lib/dao/user_dao.dart
- Migrado para usar sintaxe MySQL
- Tabela: `usuarios` (em vez de `users`)
- Colunas: `nome`, `email`, `senha`, `papel`
- Métodos adaptados para Results do mysql1

### 5. lib/dao/appointment_dao.dart
- Migrado para usar sintaxe MySQL
- Tabela: `agendamentos` (em vez de `appointments`)
- Colunas: `id_cliente`, `id_barbeiro`, `id_servico`, `data_hora_agendamento`, `status`
- Status adaptados: `confirmado`, `cancelado`, `concluido`

### 6. lib/dao/credit_transaction_dao.dart
- Migrado para usar sintaxe MySQL
- Tabelas: `transacoes` e `carteiras`
- Implementa lógica de carteira digital
- Atualiza saldo automaticamente nas transações

### 7. lib/dao/service_dao.dart
- Migrado para usar sintaxe MySQL
- Tabela: `servicos` (em vez de `services`)
- Colunas: `id_barbeiro`, `nome`, `duracao_minutos`, `preco_creditos`

### 8. lib/services/credit_service.dart
- Substituído SharedPreferences por consultas MySQL
- Utiliza tabela `carteiras` para armazenar saldos
- Registra todas as transações na tabela `transacoes`
- Métodos agora requerem userId como parâmetro

### 9. lib/services/user_service.dart
- Adicionados métodos `getUserId()` e `setUserId()`
- Permite armazenar e recuperar o ID do usuário logado

### 10. lib/screens/perfil_screen.dart
- Atualizado para usar userId nas chamadas do CreditService
- Carrega userId do UserService

### 11. lib/screens/confirmacao_screen.dart
- Atualizado para usar userId nas operações de crédito
- Busca userId antes de realizar transações

## Estrutura do Banco MySQL

O sistema agora utiliza as seguintes tabelas principais:

- **usuarios**: Dados dos usuários (clientes e barbeiros)
- **carteiras**: Saldos de créditos dos clientes
- **transacoes**: Histórico de movimentações de créditos
- **agendamentos**: Agendamentos realizados
- **servicos**: Serviços oferecidos pelos barbeiros
- **produtos**: Produtos disponíveis para venda
- **vendas_produtos**: Vendas de produtos
- **taxas_agendamento**: Taxas de garantia dos agendamentos

## Funcionalidades Implementadas

### Sistema de Carteira Digital
- Saldo armazenado na tabela `carteiras`
- Transações registradas na tabela `transacoes`
- Tipos: `credito` (adição) e `debito` (uso)

### Sistema de Taxas
- Taxa de garantia de 50% do valor do serviço
- Cobrança automática no agendamento
- Reembolso automático na conclusão do serviço

### Triggers e Procedures
O banco inclui triggers automáticos para:
- Atualização de horários disponíveis
- Cobrança e reembolso de taxas
- Notificações de mudança de status
- Controle de estoque de produtos

## Próximos Passos

1. **Configurar Conexão**: Ajustar as configurações de conexão em `database_config.dart`
2. **Testar Conexão**: Verificar se o banco MySQL está acessível
3. **Executar Script**: Garantir que o script SQL fornecido foi executado
4. **Implementar Login**: Atualizar sistema de login para salvar userId
5. **Criar Carteira**: Garantir que carteira seja criada no primeiro login
6. **Testes**: Realizar testes completos das funcionalidades

## Observações Importantes

- Todos os métodos do CreditService agora requerem userId
- Status de agendamentos mudaram para português: `confirmado`, `cancelado`, `concluido`
- O sistema agora suporta múltiplos barbeiros e produtos
- Implementado sistema completo de taxas de garantia
- É necessário implementar o salvamento do userId no login
- A carteira do usuário deve ser criada automaticamente no primeiro acesso

## Dependência Atualizada

Lembre-se de executar `flutter pub get` após as alterações no pubspec.yaml para instalar a dependência mysql1.