class ApiConfig {
  static const String baseUrl = 'http://localhost:3001/api';
  static const String apiVersion = '/v1';

  // Endpoints
  static const String auth = '$apiVersion/auth';
  static const String users = '$apiVersion/users';
  static const String appointments = '$apiVersion/appointments';
  static const String barbershops = '$apiVersion/barbershops';
  static const String services = '$apiVersion/services';
  static const String products = '$apiVersion/products';
  static const String credits = '$apiVersion/credits';

  // Headers padrão
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
