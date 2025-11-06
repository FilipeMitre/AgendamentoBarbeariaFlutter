# Telas de Barbeiros

Este diretório contém as telas específicas para barbeiros da aplicação.

## Telas Implementadas

### BarberHomeScreen
- **Arquivo**: `barber_home_screen.dart`
- **Descrição**: Tela inicial específica para barbeiros
- **Funcionalidades**:
  - Saudação personalizada baseada no horário
  - Estatísticas do dia (agendamentos e receita estimada)
  - Lista de agendamentos do dia atual
  - Botões de ação rápida (Ver Agenda, Agendar)
  - Integração com dados reais do barbeiro logado
  - Pull-to-refresh para atualizar dados
  - Estados de loading e vazio apropriados

### BarberScheduleScreen
- **Arquivo**: `barber_schedule_screen.dart`
- **Descrição**: Tela de cronograma/agenda do barbeiro
- **Funcionalidades**:
  - Seletor de dias (7 dias a partir de hoje)
  - Lista de agendamentos por data selecionada
  - Ações de cancelar e concluir agendamentos
  - Informações detalhadas de cada agendamento
  - Contador de agendamentos do dia
  - Pull-to-refresh para atualizar dados
  - Estados de loading e vazio apropriados
  - Integração com dados reais do barbeiro logado

## Serviços Relacionados

### BarberDashboardService
- **Arquivo**: `../../services/barber_dashboard_service.dart`
- **Métodos Adicionais**:
  - `getTodayAppointments(int barberId)`: Busca agendamentos do dia atual
  - `getAppointmentsByDate(int barberId, DateTime date)`: Busca agendamentos por data específica
  - `cancelAppointment(int appointmentId)`: Cancela um agendamento
  - `completeAppointment(int appointmentId)`: Marca agendamento como concluído

## Integração com a Navegação

A tela foi integrada ao sistema de navegação baseado em roles:
- Barbeiros veem `BarberHomeScreen` como tela inicial na aba "Início"
- Substitui a tela genérica `HomeScreen` para uma experiência personalizada

## Estrutura do Banco de Dados

A tela utiliza as seguintes tabelas do banco:
- `usuarios`: Para informações do barbeiro logado
- `agendamentos`: Para agendamentos do dia
- `servicos`: Para informações dos serviços e preços
- Relacionamentos com `usuarios` (clientes) para nomes dos clientes

## Características Técnicas

1. **Dados em Tempo Real**
   - Agendamentos filtrados por data atual (`CURDATE()`)
   - Cálculo automático da receita estimada
   - Status dos agendamentos (confirmado, pendente, cancelado)

2. **Interface Responsiva**
   - Cards de estatísticas com cores diferenciadas
   - Lista de agendamentos com horários formatados
   - Estados vazios com mensagens apropriadas

3. **Experiência do Usuário**
   - Saudação baseada no horário (Bom dia, Boa tarde, Boa noite)
   - Refresh manual e automático
   - Navegação para telas relacionadas (agenda, agendamento)

## Próximas Implementações

- Tela de gerenciamento de serviços do barbeiro
- Tela de configuração de horários disponíveis
- Tela de relatórios individuais do barbeiro
- Funcionalidades de check-in/check-out de clientes