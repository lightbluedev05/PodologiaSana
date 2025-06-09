import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/productos_controller.dart';
import '../../models/producto_model.dart';

class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductosController>(context, listen: false).loadProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductosController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
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
                    onPressed: controller.selectedIds.isEmpty
                        ? null
                        : () async => controller.deleteSelected(),
                    icon: const Icon(Icons.delete),
                    label: const Text("Eliminar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredProductos.length,
                itemBuilder: (context, index) {
                  final producto = controller.filteredProductos[index];
                  final isSelected = controller.selectedIds.contains(producto.id);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => controller.toggleSelection(producto.id),
                      ),
                      title: Text(producto.nombre),
                      subtitle: Text(
                          'Categoría: ${producto.categoria} | Stock: ${producto.stock} | Precio: S/. ${producto.precio_venta.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showFormDialog(context, producto: producto),
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

  void _showFormDialog(BuildContext context, {Producto? producto}) {
    final isEdit = producto != null;
    final controller = Provider.of<ProductosController>(context, listen: false);

    final nombreCtrl = TextEditingController(text: producto?.nombre);
    final descripcionCtrl = TextEditingController(text: producto?.descripcion);
    final precioCtrl = TextEditingController(
        text: producto != null ? producto.precio_venta.toString() : '');
    final stockCtrl = TextEditingController(
        text: producto != null ? producto.stock.toString() : '');
    final categoriaCtrl = TextEditingController(text: producto?.categoria);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Editar Producto' : 'Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: descripcionCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio de Venta'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: categoriaCtrl, decoration: const InputDecoration(labelText: 'Categoría')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text;
              final descripcion = descripcionCtrl.text;
              final precio = double.tryParse(precioCtrl.text) ?? 0.0;
              final stock = int.tryParse(stockCtrl.text) ?? 0;
              final categoria = categoriaCtrl.text;

              if (isEdit) {
                await controller.updateProducto(
                  id: producto!.id,
                  nombre: nombre,
                  descripcion: descripcion,
                  precioVenta: precio,
                  stock: stock,
                  categoria: categoria,
                );
              } else {
                await controller.addProducto(
                  nombre: nombre,
                  descripcion: descripcion,
                  precioVenta: precio,
                  stock: stock,
                  categoria: categoria,
                );
              }

              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
