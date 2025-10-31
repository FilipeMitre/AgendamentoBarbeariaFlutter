class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Erro desconhecido. Tente novamente.';
  }
}
```

---

## ✅ CHECKLIST FINAL - Todos os arquivos fornecidos:
```
✅ lib/screens/home_screen.dart (Atualizado)
✅ lib/screens/agendamento_screen.dart (NOVO)
✅ lib/screens/historico_screen.dart (NOVO)
✅ lib/screens/perfil_screen.dart (NOVO)
✅ lib/navigation/main_navigation.dart (NOVO)
✅ lib/services/api_config.dart (NOVO)
✅ lib/services/auth_service.dart (NOVO)
✅ lib/services/appointment_service.dart (NOVO)
✅ lib/services/user_service.dart (NOVO)
✅ lib/services/barbershop_service.dart (NOVO)
✅ lib/services/product_service.dart (NOVO)
✅ lib/services/token_manager.dart (NOVO)
✅ lib/services/error_handler.dart (NOVO)