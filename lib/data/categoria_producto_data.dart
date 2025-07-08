import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_producto.dart';

class CategoriaData {
  final String _url = 'https://podologia-sana.onrender.com';

  Future<List<CategoriaProducto>> getCategorias() async {
    final response = await http.get(Uri.parse("$_url/categorias-producto"));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['body']; // ← el array real
      return data.map((e) => CategoriaProducto.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar las categorías');
    }
  }

  Future<void> createCategoria(CategoriaProducto categoria) async {
    final response = await http.post(
      Uri.parse("$_url/categoria-producto"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toCreateJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear la categoría: ${response.body}');
    }
  }
}