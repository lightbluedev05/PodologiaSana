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
      Uri.parse('$baseUrl/producto'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(producto.toJson()),
    );

    print('Status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      try {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded.containsKey('body')) {
          final errorBody = decoded['body'];
          final details = errorBody['details'];

          if (details is List && details.isNotEmpty) {
            throw Exception(details.join('\n'));
          }
        }

        throw Exception('Error desconocido');
      } catch (e) {
        print('Error parseando respuesta: $e');
        throw e;
      }
    }
  }


  Future<void> updateProducto(Producto producto) async {
    final url = '$baseUrl/producto/${producto.id}';
    print(json.encode({
      'id': producto.id,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'precio_venta': producto.precio_venta,
      'stock': producto.stock,
      'categoria': producto.categoria,
    }));
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        //'id': producto.id,
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'precio_venta': producto.precio_venta,
        'stock': producto.stock,
        'categoria': producto.categoria,
      }),
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
