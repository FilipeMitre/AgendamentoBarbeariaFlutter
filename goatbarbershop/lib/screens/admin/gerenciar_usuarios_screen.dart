import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'editar_usuario_dialog.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  const GerenciarUsuariosScreen({super.key});

  @override
  State<GerenciarUsuariosScreen> createState() =>
      _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  String _filtroTipo = 'todos';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await adminProvider.carregarUsuarios(authProvider.token!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    final usuariosFiltrados = adminProvider.usuarios.where((usuario) {
      final matchTipo = _filtroTipo == 'todos' || usuario.tipoUsuario == _filtroTipo;
      final matchBusca = _searchController.text.isEmpty ||
          usuario.nome.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          usuario.email.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchTipo && matchBusca;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Administrar usuários',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar usuário...',
                    hintStyle: const TextStyle(color: Colors.grey),
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

                const SizedBox(height: 16),

                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 'todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Clientes', 'cliente'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Barbeiros', 'barbeiro'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Admins', 'admin'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuários
          Expanded(
            child: adminProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
                    ),
                  )
                : usuariosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum usuário encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: usuariosFiltrados.length,
                        itemBuilder: (context, index) {
                          final usuario = usuariosFiltrados[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUsuarioCard(usuario),
                          );
                        },
                      ),
          ),

          // Botão visualizar outros usuários
          if (usuariosFiltrados.length > 10)
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextButton(
                onPressed: () {
                  // TODO: Implementar paginação
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'visualizar outros usuários',
                      style: TextStyle(
                        color: Color(0xFFFFB84D),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFFFB84D),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String tipo) {
    final isSelected = _filtroTipo == tipo;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroTipo = tipo;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB84D) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB84D) : const Color(0xFF333333),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioCard(UserModel usuario) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                usuario.nome.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFB84D),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Tipo de usuário
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTipoColor(usuario.tipoUsuario).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getTipoColor(usuario.tipoUsuario)),
                ),
                child: Text(
                  _getTipoLabel(usuario.tipoUsuario),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getTipoColor(usuario.tipoUsuario),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Botão de editar
              GestureDetector(
                onTap: () {
                  _mostrarDialogEditar(usuario);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFFFFB84D),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'admin':
        return Colors.red;
      case 'barbeiro':
        return const Color(0xFFFFB84D);
      case 'cliente':
      default:
        return Colors.blue;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'admin':
        return 'Admin';
      case 'barbeiro':
        return 'Barbeiro';
      case 'cliente':
      default:
        return 'Cliente';
    }
  }

  void _mostrarDialogEditar(UserModel usuario) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => EditarUsuarioDialog(usuario: usuario),
    );
  }
}
