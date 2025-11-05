import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ProductService {
  final String token;

  ProductService({required this.token});

  // Listar produtos
  Future<List<Map<String, dynamic>>> getProducts({
    String? category, // 'products' ou 'drinks'
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.products}';
      if (category != null) {
        url += '?category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar produtos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Adicionar produto ao carrinho (agendamento)
  Future<void> addProductToCart({
    required String appointmentId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.appointments}/$appointmentId/products',
        ),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao adicionar produto');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
