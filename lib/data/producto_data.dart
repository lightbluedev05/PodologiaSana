import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_model.dart';

class ProductoData {
  final String baseUrl = 'https://podologia-sana.onrender.com';

  Future<List<Producto>> fetchProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/productos'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['body']['data'];
      return data.map((e) => Producto.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<void> createProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(producto.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear producto');
    }
  }

  Future<void> updateProducto(Producto producto) async {
    final url = '$baseUrl/${producto.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(producto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar producto');
    }
  }

  Future<void> deleteProducto(int id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar producto');
    }
  }
}
