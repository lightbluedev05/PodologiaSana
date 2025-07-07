import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/productos_controller.dart';
import '../../models/producto_model.dart';
import '../../controllers/categoria__producto_controller.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final TextEditingController _searchController = TextEditingController();

  final CategoriaController _categoriaController = CategoriaController();

  List<String> categorias = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Provider.of<ProductosController>(context, listen: false).loadProductos();
      categorias = await _categoriaController.obtenerNombresCategorias();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductosController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.filterProductos,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showFormDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Nuevo"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoriaFormDialog(context),
                    icon: const Icon(Icons.category),
                    label: const Text("+CATEGORIAS"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredProductos.length,
                itemBuilder: (context, index) {
                  final producto = controller.filteredProductos[index];

                  return Card(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text(
                          'Categoría: ${producto.categoria} | Stock: ${producto.stock} | Precio: S/. ${producto.precio_venta.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showFormDialog(context, producto: producto),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _showDeleteConfirmDialog(context, producto),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el producto "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('Eliminando producto ID: ${producto.id}'); // <-- AQUÍ

              try {
                final controller = Provider.of<ProductosController>(context, listen: false);
                await controller.deleteProductoById(producto.id);
                if (mounted) Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    actions: [
                      TextButton(
                        child: const Text('Cerrar'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, {Producto? producto}) {
    final isEdit = producto != null;
    final controller = Provider.of<ProductosController>(context, listen: false);

    final nombreCtrl = TextEditingController(text: producto?.nombre);
    final descripcionCtrl = TextEditingController(text: producto?.descripcion);
    final precioCtrl = TextEditingController(
        text: producto != null ? producto.precio_venta.toString() : '');
    final stockCtrl = TextEditingController(
        text: producto != null ? producto.stock.toString() : '');
    String selectedCategoria =
        producto?.categoria ?? (categorias.isNotEmpty ? categorias.first : '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          bool _isFormValid() {
            final nombre = nombreCtrl.text.trim();
            final precio = double.tryParse(precioCtrl.text);
            final stock = int.tryParse(stockCtrl.text);

            return nombre.isNotEmpty &&
                precio != null &&
                precio > 0 &&
                stock != null &&
                stock >= 0;
          }

          void _onFieldChanged() {
            setState(() {});
          }

          return AlertDialog(
            title: Text(isEdit ? 'Editar Producto' : 'Nuevo Producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  TextField(
                    controller: descripcionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  TextField(
                    controller: precioCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Precio de Venta'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  TextField(
                    controller: stockCtrl,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategoria,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categorias.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategoria = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar')),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: _isFormValid()
                    ? () async {
                  final nombre = nombreCtrl.text.trim();
                  final descripcion = descripcionCtrl.text.trim();
                  final precio = double.tryParse(precioCtrl.text) ?? 0.0;
                  final stock = int.tryParse(stockCtrl.text) ?? 0;

                  try {
                    if (isEdit) {
                      await controller.updateProducto(
                        id: producto!.id,
                        nombre: nombre,
                        descripcion: descripcion,
                        precioVenta: precio,
                        stock: stock,
                        categoria: selectedCategoria,
                      );
                    } else {
                      await controller.addProducto(
                        nombre: nombre,
                        descripcion: descripcion,
                        precioVenta: precio,
                        stock: stock,
                        categoria: selectedCategoria,
                      );
                    }

                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    // Mostrar el error como un AlertDialog, igual que en DoctoresView
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        actions: [
                          TextButton(
                            child: const Text('Cerrar'),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                    );
                  }
                }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCategoriaFormDialog(BuildContext context) {
    final codigoCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          bool _isFormValid() {
            final codigo = codigoCtrl.text.trim();
            final nombre = nombreCtrl.text.trim();

            return codigo.isNotEmpty && nombre.isNotEmpty;
          }

          return AlertDialog(
            title: const Text('Nueva Categoría'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codigoCtrl,
                  decoration: const InputDecoration(labelText: 'Código'),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _isFormValid()
                    ? () async {
                  final codigo = codigoCtrl.text.trim();
                  final nombre = nombreCtrl.text.trim();

                  try {
                    // await _categoriaController.crearCategoria(codigo: codigo, nombre: nombre);
                    categorias = await _categoriaController.obtenerNombresCategorias();
                    setState(() {}); // Recarga dropdown de categorías

                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cerrar'),
                          )
                        ],
                      ),
                    );
                  }
                }
                    : null,
                child: const Text('Guardar'), // <- ESTA LÍNEA FALTABA
              ),
            ],
          );
        },
      ),
    );
  }
}