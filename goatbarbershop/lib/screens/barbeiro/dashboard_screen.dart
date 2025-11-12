import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/barbeiro_provider.dart';
import '../../widgets/dashboard_card.dart';

class BarberDashboardScreen extends StatefulWidget {
  @override
  _BarberDashboardScreenState createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os dados do dashboard ao iniciar a tela
    Provider.of<BarbeiroProvider>(context, listen: false).fetchBarberDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final barberProvider = Provider.of<BarbeiroProvider>(context);
    final dashboardData = barberProvider.dashboardData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Desempenho'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              barberProvider.fetchBarberDashboard();
            },
          ),
        ],
      ),
      body: barberProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : dashboardData == null
              ? Center(
                  child: Text('Não foi possível carregar os dados.'),
                )
              : RefreshIndicator(
                  onRefresh: () => barberProvider.fetchBarberDashboard(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      DashboardCard(
                        icon: Icons.calendar_today,
                        title: 'Agendamentos Hoje',
                        value: dashboardData['agendamentosHoje']?.toString() ?? '0',
                        color: Colors.teal,
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.next_plan, color: Colors.blueAccent, size: 40),
                          title: Text('Próximo Agendamento'),
                          subtitle: Text(
                            dashboardData['proximoAgendamento'] != null
                                ? '${dashboardData['proximoAgendamento']['data_agendamento']} às ${dashboardData['proximoAgendamento']['horario']}'
                                : 'Nenhum agendamento futuro',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navegar para detalhes do agendamento
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      DashboardCard(
                        icon: Icons.attach_money,
                        title: 'Total a Receber',
                        value: 'R\$ ${dashboardData['totalReceber']?.toStringAsFixed(2) ?? '0.00'}',
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
    );
  }
}