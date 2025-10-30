import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                const GOATLogoWithText(),
                
                const SizedBox(height: 60),
                
                // Campo Nome
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Digite seu nome',
                  icon: Icons.person_outline,
                ),
                
                const SizedBox(height: 16),
                
                // Campo CPF
                CustomTextField(
                  controller: _cpfController,
                  hintText: 'Digite seu cpf',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
                
                // Campo E-mail
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Digite seu e-mail',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 16),
                
                // Campo Senha
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Digite sua senha',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botão Cadastrar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar cadastro
                    },
                    child: const Text('cadastrar'),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Divider "Ou continue com"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.inputBorder, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ou continue com',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.inputBorder, thickness: 1),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Botões sociais
                const SocialButtonsRow(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}