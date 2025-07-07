import 'package:flutter/material.dart';
import '../data/producto_data.dart';
import '../models/producto_model.dart';

class ProductosController extends ChangeNotifier {
  final ProductoData _data = ProductoData();
  List<Producto> _productos = [];
  List<Producto> filteredProductos = [];
  Set<int> selectedIds = {};

  List<Producto> get productos => filteredProductos;

  Future<void> loadProductos() async {
    try {
      _productos = await _data.fetchProductos();

      _productos = _productos.where((p) => p.estado?.toLowerCase() == 'activo').toList();

      filteredProductos = List.from(_productos);
      notifyListeners();
    } catch (e) {
      print("Error al cargar productos: $e");
    }
  }


  void filterProductos(String query) {
    final q = query.toLowerCase();
    filteredProductos = _productos.where((p) {
      return p.nombre.toLowerCase().contains(q) ||
          p.descripcion.toLowerCase().contains(q) ||
          p.categoria.toLowerCase().contains(q);
    }).toList();
    notifyListeners();
  }

  Future<void> addProducto({
    required String nombre,
    required String descripcion,
    required double precioVenta,
    required int stock,
    required String categoria,
  }) async {
    final nuevo = Producto(
      nombre: nombre,
      descripcion: descripcion,
      precio_venta: precioVenta,
      stock: stock,
      categoria: categoria,
      estado: "activo",
    );
    await _data.createProducto(nuevo);
    await loadProductos();
  }

  Future<void> updateProducto({
    required int id,
    required String nombre,
    required String descripcion,
    required double precioVenta,
    required int stock,
    required String categoria,
  }) async {
    final actualizado = Producto(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      precio_venta: precioVenta,
      stock: stock,
      categoria: categoria,
      estado: "activo",
    );
    await _data.updateProducto(actualizado);
    await loadProductos();
  }

  Future<void> deleteProductoById(int id) async {
    await _data.deleteProducto(id);
    await loadProductos();
  }


  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }
}
