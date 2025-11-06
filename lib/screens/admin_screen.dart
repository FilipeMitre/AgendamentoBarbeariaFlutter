import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  List<UserModel> _users = [];
  bool _isLoading = true;

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

  Future<void> _promoteToBarber(UserModel user) async {
    try {
      final success = await _adminService.promoteToBarber(user.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} promovido a barbeiro!')),
        );
        _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _demoteToClient(UserModel user) async {
    try {
      final success = await _adminService.demoteToClient(user.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} rebaixado a cliente!')),
        );
        _loadUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administração'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: AppColors.cardBackground,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(user.role),
                        child: Icon(
                          _getRoleIcon(user.role),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRoleText(user.role),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: user.role != 'admin'
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'promote' && user.role == 'cliente') {
                                  _promoteToBarber(user);
                                } else if (value == 'demote' && user.role == 'barbeiro') {
                                  _demoteToClient(user);
                                }
                              },
                              itemBuilder: (context) => [
                                if (user.role == 'cliente')
                                  const PopupMenuItem(
                                    value: 'promote',
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_upward, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Promover a Barbeiro'),
                                      ],
                                    ),
                                  ),
                                if (user.role == 'barbeiro')
                                  const PopupMenuItem(
                                    value: 'demote',
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_downward, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Rebaixar a Cliente'),
                                      ],
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'barbeiro':
        return Colors.blue;
      case 'cliente':
      default:
        return Colors.grey;
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