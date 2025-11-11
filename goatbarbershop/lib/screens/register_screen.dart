import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        nome: _nameController.text.trim(),
        cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao cadastrar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo e título
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GIAT',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 36,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BARBERSHOP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Campo Nome
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Digite seu nome',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateName,
                ),

                const SizedBox(height: 16),

                // Campo CPF
                CustomTextField(
                  controller: _cpfController,
                  hintText: 'Digite seu cpf',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateCPF,
                  onChanged: (value) {
                    final formatted = Validators.formatCPF(value);
                    if (formatted != value) {
                      _cpfController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Campo E-mail
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Digite seu e-mail',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 16),

                // Campo Senha
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Digite sua senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.validatePassword,
                ),

                const SizedBox(height: 32),

                // Botão Cadastrar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleRegister,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text('cadastrar'),
                  ),
                ),

                const SizedBox(height: 32),

                // Ou continue com
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ou continue com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 24),

                // Botões de login social
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      icon: 'assets/icons/google.png',
                      onPressed: () {
                        // TODO: Implementar cadastro com Google
                      },
                    ),
                    const SizedBox(width: 16),
                    SocialLoginButton(
                      icon: 'assets/icons/apple.png',
                      onPressed: () {
                        // TODO: Implementar cadastro com Apple
                      },
                    ),
                    const SizedBox(width: 16),
                    SocialLoginButton(
                      icon: 'assets/icons/facebook.png',
                      onPressed: () {
                        // TODO: Implementar cadastro com Facebook
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
