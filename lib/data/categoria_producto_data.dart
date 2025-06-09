import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_producto.dart';

class CategoriaData {
  final String _url = 'https://podologia-sana.onrender.com/categorias-producto';

  Future<List<CategoriaProducto>> getCategorias() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['body']; // ← el array real
      return data.map((e) => CategoriaProducto.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar las categorías');
    }
  }
}