import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // The base URL provided in project PDF
  static const String baseUrl = "https://api.escuelajs.co/api/v1";

  // Fetch all products for the Home Screen
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/products"));

      if (response.statusCode == 200) {
        // Successfully got the data
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("API Error: $e");
      return [];
    }
  }

  // Fetch a single product for the Detail Screen
  Future<Map<String, dynamic>> fetchProductDetails(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/products/$id"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load product details");
    }
  }
}