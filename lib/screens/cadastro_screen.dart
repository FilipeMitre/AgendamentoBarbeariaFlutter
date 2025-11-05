import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_widgets.dart';
import '../utils/validators.dart';
import '../navigation/main_navigation.dart';
import '../services/user_service.dart';
import '../services/credit_service.dart';
import '../dao/user_dao.dart';
import '../models/user_model.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final UserDao _userDao = UserDao();

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
            child: Form(
              key: _formKey,
              child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                const GOATLogoWithText(),
                
                const SizedBox(height: 60),
                
                // Campo Nome
                TextFormField(
                  controller: _nameController,
                  validator: Validators.validateName,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Digite seu nome',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo CPF
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateCPF,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    _CPFFormatter(),
                  ],
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Digite seu CPF (000.000.000-00)',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Digite seu e-mail',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Digite sua senha (mínimo 8 caracteres)',
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
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
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botão Cadastrar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrar,
                    child: _isLoading 
                        ? CircularProgressIndicator(color: Colors.black)
                        : const Text('cadastrar'),
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
      ),
    );
  }
  
  void _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Criar modelo do usuário
      final user = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        cpf: _cpfController.text.trim(),
        password: _passwordController.text,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      // Salvar no banco
      final result = await _userDao.create(user);
      
      if (result > 0) {
        // Buscar o usuário recém-criado para pegar o ID
        final createdUser = await _userDao.getByEmail(user.email);
        
        if (createdUser != null) {
          // Salvar dados do usuário localmente
          await UserService.setUserId(createdUser.id!);
          await UserService.setUserData(
            createdUser.name,
            createdUser.email,
            '(71) 99999-9999',
          );
          
          // Criar carteira inicial com saldo 0
          await CreditService.setCredits(0.0, createdUser.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cadastro realizado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Redirecionar para navegação principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        } else {
          throw Exception('Erro ao recuperar dados do usuário');
        }
      } else {
        throw Exception('Erro ao criar usuário');
      }
    } catch (e) {
      print('Erro no cadastro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao realizar cadastro. Email já existe ou tente novamente.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }
}

// Formatador de CPF
class _CPFFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length <= 11) {
      final formatted = Validators.formatCPF(text);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return oldValue;
  }
}