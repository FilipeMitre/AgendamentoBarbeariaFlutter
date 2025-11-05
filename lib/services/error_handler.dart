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
