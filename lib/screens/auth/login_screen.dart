import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/atoms/custom_text_field.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              CustomTextField(controller: _passCtrl, label: 'Senha', obscure: true),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Entrar',
                loading: auth.isLoading,
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? true) {
                    await context.read<AuthProvider>().login(_emailCtrl.text, _passCtrl.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}