# Telas Administrativas e de Barbeiros

Este diretório contém as telas específicas para diferentes tipos de usuários da aplicação.

## Telas Implementadas

### AdminHomeScreen
- **Arquivo**: `admin_home_screen.dart`
- **Descrição**: Tela inicial específica para administradores
- **Funcionalidades**:
  - Dashboard com estatísticas gerais do sistema
  - Contadores de usuários, barbeiros, agendamentos e receita
  - Menu de administração com acesso às funcionalidades administrativas
  - Integração com o banco de dados para dados em tempo real
  - Refresh para atualizar dados

### BarberHomeScreen
- **Arquivo**: `barber_home_screen.dart`
- **Descrição**: Tela inicial específica para barbeiros
- **Funcionalidades**:
  - Dashboard com estatísticas do barbeiro
  - Contadores de agendamentos confirmados, concluídos, serviços e receita
  - Menu específico do barbeiro
  - Lista dos próximos agendamentos
  - Integração com dados específicos do barbeiro logado

### AdminUsersScreen
- **Arquivo**: `admin_users_screen.dart`
- **Descrição**: Tela de gerenciamento de usuários para administradores
- **Funcionalidades**:
  - Lista todos os usuários do sistema
  - Paginação para melhor performance
  - Alteração de papel (cliente ↔ barbeiro)
  - Contador total de usuários
  - Refresh manual dos dados
  - Proteção contra alteração de administradores
  - Integração completa com AdminService

### AdminServicesScreen
- **Arquivo**: `admin_services_screen.dart`
- **Descrição**: Tela de gerenciamento de serviços para administradores
- **Funcionalidades**:
  - Lista todos os serviços do sistema
  - Adicionar novos serviços
  - Editar serviços existentes
  - Excluir serviços
  - Seleção de barbeiro por dropdown
  - Contador total de serviços
  - Refresh manual dos dados
  - Integração com tabela servicos do banco

### AdminReportsScreen
- **Arquivo**: `admin_reports_screen.dart`
- **Descrição**: Tela de relatórios e estatísticas para administradores
- **Funcionalidades**:
  - Relatórios dos últimos 30 dias
  - Receita total com comparação do período anterior
  - Total de agendamentos e comparação
  - Taxa de cancelamento calculada
  - Vendas de produtos e receita
  - Ranking dos top barbeiros por receita
  - Refresh manual dos dados
  - Integração com múltiplas tabelas do banco

## Serviços Relacionados

### DashboardService
- **Arquivo**: `../../services/dashboard_service.dart`
- **Descrição**: Serviço para buscar estatísticas gerais do sistema
- **Métodos**:
  - `getDashboardStats()`: Busca estatísticas gerais
  - `getRecentAppointments()`: Busca agendamentos recentes

### BarberDashboardService
- **Arquivo**: `../../services/barber_dashboard_service.dart`
- **Descrição**: Serviço para buscar dados específicos do barbeiro
- **Métodos**:
  - `getBarberStats(int barberId)`: Busca estatísticas do barbeiro
  - `getUpcomingAppointments(int barberId)`: Busca próximos agendamentos

### AdminServicesService
- **Arquivo**: `../../services/admin_services_service.dart`
- **Descrição**: Serviço para gerenciar serviços administrativamente
- **Métodos**:
  - `getAllServices()`: Busca todos os serviços com informações do barbeiro
  - `addService(ServiceModel service)`: Adiciona novo serviço
  - `updateService(ServiceModel service)`: Atualiza serviço existente
  - `deleteService(int serviceId)`: Exclui serviço
  - `getBarbers()`: Busca lista de barbeiros para dropdown

### AdminReportsService
- **Arquivo**: `../../services/admin_reports_service.dart`
- **Descrição**: Serviço para gerar relatórios e estatísticas
- **Métodos**:
  - `getReportsData()`: Busca dados gerais dos relatórios (receita, agendamentos, cancelamentos, vendas)
  - `getTopBarbers()`: Busca ranking dos barbeiros por receita
  - `getComparisonData()`: Busca dados do período anterior para comparação

## Integração com a Navegação

As telas foram integradas ao sistema de navegação baseado em roles:
- Administradores veem `AdminHomeScreen` como tela inicial
- Barbeiros veem `BarberHomeScreen` como tela inicial
- Clientes continuam vendo `HomeScreen` como tela inicial

## Estrutura do Banco de Dados

As telas utilizam as seguintes tabelas do banco:
- `usuarios`: Para informações dos usuários
- `agendamentos`: Para dados de agendamentos
- `servicos`: Para informações dos serviços
- `carteiras` e `transacoes`: Para dados financeiros

## Próximas Implementações

- Telas de gerenciamento de serviços para barbeiros
- Telas de relatórios detalhados
- Telas de configuração de horários
- Telas de gerenciamento de produtos