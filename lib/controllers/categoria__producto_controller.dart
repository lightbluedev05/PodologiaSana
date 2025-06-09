import '../data/categoria_producto_data.dart';
import '../models/categoria_producto.dart';

class CategoriaController {
  final CategoriaData _data = CategoriaData();

  Future<List<CategoriaProducto>> obtenerCategorias() {
    return _data.getCategorias();
  }

  Future<List<String>> obtenerNombresCategorias() async {
    final categorias = await obtenerCategorias();
    return categorias.map((cat) => cat.nombre).toList();
  }
}