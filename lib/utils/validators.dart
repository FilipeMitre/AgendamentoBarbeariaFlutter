class Validators {
  // REGEX para email
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // REGEX para CPF (formato: 000.000.000-00)
  static final RegExp _cpfRegex = RegExp(
    r'^\d{3}\.\d{3}\.\d{3}-\d{2}$',
  );

  // REGEX para senha (mínimo 8 caracteres, pelo menos 1 letra e 1 número)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validateCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'CPF é obrigatório';
    }
    if (!_cpfRegex.hasMatch(cpf)) {
      return 'CPF deve estar no formato 000.000.000-00';
    }
    if (!_isValidCPF(cpf)) {
      return 'CPF inválido';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (password.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!_passwordRegex.hasMatch(password)) {
      return 'Senha deve conter pelo menos 1 letra e 1 número';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  // Validação de CPF usando algoritmo oficial
  static bool _isValidCPF(String cpf) {
    // Remove formatação
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
    
    // Calcula primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;
    
    if (int.parse(cpf[9]) != firstDigit) return false;
    
    // Calcula segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;
    
    return int.parse(cpf[10]) == secondDigit;
  }

  // Formatador de CPF
  static String formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9) return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }
}