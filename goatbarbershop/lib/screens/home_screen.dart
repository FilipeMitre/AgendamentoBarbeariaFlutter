import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/agendamento_provider.dart';
import '../models/barbeiro_model.dart';
import '../models/agendamento_model.dart';
import '../widgets/barbeiro_card.dart';
import '../widgets/agendamento_ativo_card.dart';
import 'agendar_corte_screen.dart';
import 'carteira_screen.dart';
import 'avaliacao_screen.dart';
import '../utils/admin_guard.dart';
import 'perfil_screen.dart';
import 'meus_agendamentos_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'barbeiro/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar agendamentos ativos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null && authProvider.token != null) {
        Provider.of<AgendamentoProvider>(context, listen: false)
            .carregarAgendamentosAtivos(authProvider.user!.id!, authProvider.token!);
      }
    });
  }

  // Dados mockados - depois virão da API
  final List<BarbeiroModel> _barbeirosDestaque = [
    BarbeiroModel(
      id: 1,
      nome: 'GOATbarber - Pituba',
      avaliacao: 5.0,
      distancia: 0.5,
      status: 'Aberto',
      endereco: 'Pituba',
    ),
    BarbeiroModel(
      id: 2,
      nome: 'GOATbarber - Imbui',
      avaliacao: 4.8,
      distancia: 2.4,
      status: 'Em Breve',
      endereco: 'Imbui',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final agendamentoProvider = Provider.of<AgendamentoProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - AQUI É ONDE VOCÊ VAI MODIFICAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fala, ${user?.nome.split(' ').first ?? 'Usuário'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFFFFB84D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Salvador-BA',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // MODIFICAÇÃO AQUI: Adicionar Row com botões
                    Row(
                      children: [
                        // Botão Admin (só aparece para admins)
                        if (user?.tipoUsuario == 'admin') ...[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFB84D),
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.admin_panel_settings,
                                color: Color(0xFFFFB84D),
                              ),
                              onPressed: () {
                                AdminGuard.navigateToAdmin(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Botão de notificações
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF333333),
                            ),
                          ),
                          child: Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // TODO: Navegar para notificações
                                },
                              ),
                              if (agendamentoProvider.agendamentosAtivos.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquise locais',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFB84D)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Agendamento Ativo (se existir)
                if (agendamentoProvider.agendamentosAtivos.isNotEmpty) ...[
                  AgendamentoAtivoCard(
                    agendamento: agendamentoProvider.agendamentosAtivos.first,
                    onTap: () {
                      // Navegar para detalhes do agendamento
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Último local visitado
                const Text(
                  'Último local visitado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Card do último local com imagem
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'GOATbarber',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Segunda à Sexta: 9h-19h',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Aberto',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgendarCorteScreen(
                                      barbeiro: _barbeirosDestaque[0],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Agendar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Barbarias próximas
                const Text(
                  'Barbarias próximas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de barbeiros
                ..._barbeirosDestaque.map((barbeiro) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BarbeiroCard(
                      barbeiro: barbeiro,
                      onTap: () {
                        if (barbeiro.status == 'Aberto') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgendarCorteScreen(
                                barbeiro: barbeiro,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true, () {}),
              if (user?.tipoUsuario == 'admin')
                _buildNavItem(Icons.dashboard, 'Dashboard', false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                  );
                }),
              if (user?.tipoUsuario == 'barbeiro')
                _buildNavItem(Icons.dashboard, 'Dashboard', false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarberDashboardScreen()),
                  );
                }),
              _buildNavItem(Icons.account_balance_wallet, 'Carteira', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarteiraScreen()),
                );
              }),
              _buildNavItem(Icons.calendar_today, 'Agendamentos', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MeusAgendamentosScreen()),
                );
              }),
              _buildNavItem(Icons.person_outline, 'Perfil', false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFFFB84D) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFFFFB84D) : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }


}
