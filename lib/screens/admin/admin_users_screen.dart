import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/admin_service.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _usersPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar usuários: $e')),
        );
      }
    }
  }

  Future<void> _changeUserRole(UserModel user, String newRole) async {
    try {
      bool success = false;
      if (newRole == 'barbeiro' && user.role == 'cliente') {
        success = await _adminService.promoteToBarber(user.id!);
      } else if (newRole == 'cliente' && user.role == 'barbeiro') {
        success = await _adminService.demoteToClient(user.id!);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} alterado para $newRole com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers(); // Recarrega a lista
      } else {
        throw Exception('Falha ao alterar papel do usuário');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar papel: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<UserModel> get _paginatedUsers {
    final startIndex = _currentPage * _usersPerPage;
    final endIndex = (startIndex + _usersPerPage).clamp(0, _users.length);
    return _users.sublist(startIndex, endIndex);
  }

  bool get _hasNextPage {
    return (_currentPage + 1) * _usersPerPage < _users.length;
  }

  bool get _hasPreviousPage {
    return _currentPage > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Administrar usuários',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Contador de usuários
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total de usuários: ${_users.length}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Página ${_currentPage + 1}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Lista de usuários
                  Expanded(
                    child: _paginatedUsers.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum usuário encontrado',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _paginatedUsers.length,
                            itemBuilder: (context, index) {
                              final user = _paginatedUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                  ),

                  SizedBox(height: 16),

                  // Controles de paginação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _hasPreviousPage
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        icon: Icon(
                          Icons.arrow_back,
                          color: _hasPreviousPage ? AppColors.primary : AppColors.textSecondary,
                        ),
                        label: Text(
                          'Anterior',
                          style: TextStyle(
                            color: _hasPreviousPage ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _hasNextPage
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                        icon: Icon(
                          Icons.arrow_forward,
                          color: _hasNextPage ? AppColors.primary : AppColors.textSecondary,
                        ),
                        label: Text(
                          'Próxima',
                          style: TextStyle(
                            color: _hasNextPage ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isBarbeiro = user.role == 'barbeiro';
    final isAdmin = user.role == 'admin';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getRoleIcon(user.role),
              color: _getRoleColor(user.role),
              size: 28,
            ),
          ),

          SizedBox(width: 16),

          // Info do usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleText(user.role),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12),

          // Toggle de papel (apenas para não-admins)
          if (!isAdmin)
            Row(
              children: [
                // Botão cliente
                GestureDetector(
                  onTap: () {
                    if (isBarbeiro) {
                      _showChangeRoleDialog(user, 'cliente');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !isBarbeiro ? AppColors.primary : AppColors.cardBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: !isBarbeiro ? AppColors.primary : AppColors.inputBorder,
                      ),
                    ),
                    child: Text(
                      'cliente',
                      style: TextStyle(
                        color: !isBarbeiro ? Colors.black : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Botão barbeiro
                GestureDetector(
                  onTap: () {
                    if (!isBarbeiro) {
                      _showChangeRoleDialog(user, 'barbeiro');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBarbeiro ? AppColors.success : AppColors.cardBackground,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: isBarbeiro ? AppColors.success : AppColors.inputBorder,
                      ),
                    ),
                    child: Text(
                      'barbeiro',
                      style: TextStyle(
                        color: isBarbeiro ? Colors.white : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserModel user, String newRole) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Alterar papel do usuário',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja alterar ${user.name} para $newRole?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeUserRole(user, newRole);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'barbeiro':
        return AppColors.success;
      case 'cliente':
      default:
        return AppColors.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'barbeiro':
        return Icons.content_cut;
      case 'cliente':
      default:
        return Icons.person;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'barbeiro':
        return 'Barbeiro';
      case 'cliente':
      default:
        return 'Cliente';
    }
  }
}