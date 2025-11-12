import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/dashboard_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os dados do dashboard ao iniciar a tela
    Provider.of<AdminProvider>(context, listen: false).fetchAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final dashboardData = adminProvider.dashboardData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard do Administrador'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              adminProvider.fetchAdminDashboard();
            },
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : dashboardData == null
              ? Center(
                  child: Text('Não foi possível carregar os dados.'),
                )
              : RefreshIndicator(
                  onRefresh: () => adminProvider.fetchAdminDashboard(),
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16.0),
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: <Widget>[
                      DashboardCard(
                        icon: Icons.people,
                        title: 'Total de Usuários',
                        value: dashboardData['totalUsuarios']?.toString() ?? '0',
                        color: Colors.blue,
                      ),
                      DashboardCard(
                        icon: Icons.content_cut,
                        title: 'Total de Barbeiros',
                        value: dashboardData['totalBarbeiros']?.toString() ?? '0',
                        color: Colors.orange,
                      ),
                      DashboardCard(
                        icon: Icons.event,
                        title: 'Total de Agendamentos',
                        value: dashboardData['totalAgendamentos']?.toString() ?? '0',
                        color: Colors.green,
                      ),
                      DashboardCard(
                        icon: Icons.monetization_on,
                        title: 'Receita Total',
                        value: 'R\$ ${dashboardData['receitaTotal']?.toStringAsFixed(2) ?? '0.00'}',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
    );
  }
}