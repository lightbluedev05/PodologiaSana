import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/recepcionista_controller.dart';
import '../../models/producto_model.dart';
import '../../models/ventas_model.dart';
import '../../data/ventas_data.dart';

class RegistrarVentasView extends StatefulWidget {
  const RegistrarVentasView({super.key});

  @override
  State<RegistrarVentasView> createState() => _RegistrarVentasViewState();
}

class _RegistrarVentasViewState extends State<RegistrarVentasView>
    with TickerProviderStateMixin {
  final _controller = RecepcionistaController();
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'nombre'; // 'nombre' o 'categoria'
  List<Producto> _filteredProductos = [];
  Map<int, int> _carrito = {};
  double _totalVenta = 0.0;

  // Nuevos campos para la venta
  String _tipoPago = 'efectivo'; // 'efectivo', 'tarjeta', 'transferencia'
  final TextEditingController _codigoOperacionController = TextEditingController();
  final TextEditingController _dniClienteController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadProductos();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadProductos() async {
    await _controller.cargarProductos();
    setState(() {
      _filteredProductos = _controller.productos;
      _isLoading = false;
    });

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _filterProductos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProductos = _controller.productos;
      } else {
        _filteredProductos = _controller.productos.where((producto) {
          if (_filterType == 'nombre') {
            return producto.nombre.toLowerCase().contains(query.toLowerCase());
          } else {
            return producto.categoria.toLowerCase().contains(
                query.toLowerCase());
          }
        }).toList();
      }
    });
  }

  void _changeFilterType(String newType) {
    setState(() {
      _filterType = newType;
      // Reaplica el filtro con el nuevo tipo
      _filterProductos(_searchQuery);
    });
  }

  void _agregarAlCarrito(Producto producto) {
    HapticFeedback.lightImpact();

    final cantidadActual = _carrito[producto.id] ?? 0;

    // Verificar si hay stock disponible
    if (cantidadActual >= producto.stock) {
      // Mostrar notificación de stock insuficiente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Stock insuficiente para ${producto.nombre}'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _carrito[producto.id] = cantidadActual + 1;
      _calcularTotal();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            Text('${producto.nombre} agregado al carrito'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removerDelCarrito(int productoId) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_carrito.containsKey(productoId)) {
        final cantidadActual = _carrito[productoId]!;
        if (cantidadActual > 1) {
          _carrito[productoId] = cantidadActual - 1;
        } else {
          _carrito.remove(productoId);
        }
        _calcularTotal();
      }
    });

    final producto = _controller.productos.firstWhere((p) =>
    p.id == productoId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.remove_shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            Text('${producto.nombre} removido del carrito'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _agregarAlCarritoModal(Producto producto) {
    HapticFeedback.lightImpact();

    final cantidadActual = _carrito[producto.id] ?? 0;

    // Verificar si hay stock disponible
    if (cantidadActual >= producto.stock) {
      // Mostrar notificación de stock insuficiente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Stock insuficiente para ${producto.nombre}'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _carrito[producto.id] = cantidadActual + 1;
      _calcularTotal();
    });
  }

  void _removerDelCarritoModal(int productoId) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_carrito.containsKey(productoId)) {
        final cantidadActual = _carrito[productoId]!;
        if (cantidadActual > 1) {
          _carrito[productoId] = cantidadActual - 1;
        } else {
          _carrito.remove(productoId);
        }
        _calcularTotal();
      }
    });
  }

  void _calcularTotal() {
    double total = 0;
    _carrito.forEach((productoId, cantidad) {
      final producto = _controller.productos.firstWhere((p) =>
      p.id == productoId);
      total += producto.precio_venta * cantidad;
    });
    _totalVenta = total;
  }

  void _mostrarCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCarritoModal(),
    );
  }

  void _limpiarCamposVenta() {
    _tipoPago = 'efectivo';
    _codigoOperacionController.clear();
    _dniClienteController.clear();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _codigoOperacionController.dispose();
    _dniClienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingWidget() : _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Registrar Ventas',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.purple[700],
      elevation: 0,
      actions: [
        IconButton(
          icon: Badge(
            label: Text('${_carrito.length}'),
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          onPressed: _mostrarCarrito,
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cargando productos...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildSearchSection(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Selector de tipo de filtro
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeFilterType('nombre'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _filterType == 'nombre'
                            ? Colors.purple
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: _filterType == 'nombre'
                                ? Colors.white
                                : Colors.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Por Nombre',
                            style: TextStyle(
                              color: _filterType == 'nombre'
                                  ? Colors.white
                                  : Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeFilterType('categoria'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _filterType == 'categoria'
                            ? Colors.purple
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category,
                            color: _filterType == 'categoria'
                                ? Colors.white
                                : Colors.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Por Categoría',
                            style: TextStyle(
                              color: _filterType == 'categoria'
                                  ? Colors.white
                                  : Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: _filterProductos,
              decoration: InputDecoration(
                hintText: _filterType == 'nombre'
                    ? 'Buscar por nombre...'
                    : 'Buscar por categoría...',
                prefixIcon: Icon(
                  _filterType == 'nombre'
                      ? Icons.search
                      : Icons.category_outlined,
                  color: Colors.purple,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 columnas
          childAspectRatio: 0.85, // Aspecto más cuadrado
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _filteredProductos.length,
        itemBuilder: (context, index) {
          return _buildProductCard(_filteredProductos[index], index);
        },
      ),
    );
  }

  Widget _buildProductCard(Producto producto, int index) {
    final cantidadEnCarrito = _carrito[producto.id] ?? 0;
    final stockDisponible = producto.stock - cantidadEnCarrito;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () => _agregarAlCarrito(producto),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                stockDisponible <= 0
                    ? Colors.red.withOpacity(0.05)
                    : Colors.purple.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: stockDisponible <= 0
                    ? Colors.red.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícono del producto más grande
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              stockDisponible <= 0
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.purple.withOpacity(0.2),
                              stockDisponible <= 0
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.purple.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.inventory,
                          color: stockDisponible <= 0 ? Colors.red : Colors
                              .purple,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Nombre del producto
                    Expanded(
                      flex: 2,
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Categoría del producto
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        producto.categoria,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Stock disponible
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stockDisponible > 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stockDisponible > 0
                            ? 'Disponible: $stockDisponible'
                            : 'Sin stock',
                        style: TextStyle(
                          fontSize: 24,
                          color: stockDisponible > 0 ? Colors.green : Colors
                              .red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Precio
                    Text(
                      'S/ ${producto.precio_venta.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),

              // Cantidad en carrito
              if (cantidadEnCarrito > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$cantidadEnCarrito',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Efecto de ondas al tocar
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _agregarAlCarrito(producto),
                    splashColor: stockDisponible <= 0
                        ? Colors.red.withOpacity(0.3)
                        : Colors.purple.withOpacity(0.3),
                    highlightColor: stockDisponible <= 0
                        ? Colors.red.withOpacity(0.1)
                        : Colors.purple.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return _carrito.isNotEmpty
        ? FloatingActionButton.extended(
      onPressed: _mostrarCarrito,
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.shopping_cart),
      label: Text('S/ ${_totalVenta.toStringAsFixed(2)}'),
    )
        : const SizedBox.shrink();
  }

  Widget _buildCarritoModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle del modal
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Título
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Carrito de Compras',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Lista de productos y campos de venta
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          // Lista de productos
                          _carrito.isEmpty
                              ? Container(
                            padding: const EdgeInsets.all(40),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Carrito vacío',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Column(
                            children: [
                              // Productos en el carrito
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _carrito.length,
                                itemBuilder: (context, index) {
                                  final productoId = _carrito.keys.elementAt(
                                      index);
                                  final cantidad = _carrito[productoId]!;
                                  final producto = _controller.productos
                                      .firstWhere((p) => p.id == productoId);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(
                                                0.1),
                                            borderRadius: BorderRadius.circular(
                                                10),
                                          ),
                                          child: const Icon(Icons.inventory,
                                              color: Colors.purple),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                producto.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                'S/ ${producto.precio_venta
                                                    .toStringAsFixed(
                                                    2)} x $cantidad',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Controles de cantidad
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                                20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  _removerDelCarritoModal(
                                                      productoId);
                                                  setModalState(() {});
                                                },
                                                iconSize: 20,
                                              ),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(horizontal: 8),
                                                child: Text(
                                                  '$cantidad',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add,
                                                    color: Colors.green),
                                                onPressed: () {
                                                  _agregarAlCarritoModal(
                                                      producto);
                                                  setModalState(() {});
                                                },
                                                iconSize: 20,
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Text(
                                          'S/ ${(producto.precio_venta *
                                              cantidad).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // Campos adicionales para la venta
                              if (_carrito.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blue.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      const Text(
                                        'Datos de la Venta',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // DNI del Cliente
                                      TextField(
                                        controller: _dniClienteController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'DNI del Cliente',
                                          hintText: 'Ingrese el DNI del cliente',
                                          prefixIcon: const Icon(
                                              Icons.person, color: Colors.blue),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                10),
                                            borderSide: const BorderSide(
                                                color: Colors.blue, width: 2),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(8),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Tipo de Pago
                                      const Text(
                                        'Tipo de Pago',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              10),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          children: [
                                            RadioListTile<String>(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.money, color: Colors.green),
                                                  SizedBox(width: 8),
                                                  Text('Efectivo'),
                                                ],
                                              ),
                                              value: 'efectivo',
                                              groupValue: _tipoPago,
                                              activeColor: Colors.blue,
                                              onChanged: (value) {
                                                setModalState(() {
                                                  _tipoPago = value!;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.credit_card, color: Colors.purple),
                                                  SizedBox(width: 8),
                                                  Text('Tarjeta'),
                                                ],
                                              ),
                                              value: 'tarjeta',
                                              groupValue: _tipoPago,
                                              activeColor: Colors.blue,
                                              onChanged: (value) {
                                                setModalState(() {
                                                  _tipoPago = value!;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.account_balance, color: Colors.orange),
                                                  SizedBox(width: 8),
                                                  Text('Transferencia'),
                                                ],
                                              ),
                                              value: 'transferencia',
                                              groupValue: _tipoPago,
                                              activeColor: Colors.blue,
                                              onChanged: (value) {
                                                setModalState(() {
                                                  _tipoPago = value!;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.qr_code, color: Colors.deepPurple),
                                                  SizedBox(width: 8),
                                                  Text('Yape'),
                                                ],
                                              ),
                                              value: 'yape',
                                              groupValue: _tipoPago,
                                              activeColor: Colors.blue,
                                              onChanged: (value) {
                                                setModalState(() {
                                                  _tipoPago = value!;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.qr_code_2, color: Colors.teal),
                                                  SizedBox(width: 8),
                                                  Text('Plin'),
                                                ],
                                              ),
                                              value: 'plin',
                                              groupValue: _tipoPago,
                                              activeColor: Colors.blue,
                                              onChanged: (value) {
                                                setModalState(() {
                                                  _tipoPago = value!;
                                                });
                                              },
                                            ),
                                            RadioListTile<String>(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.qr_code_scanner, color: Colors.indigo),
                                                  SizedBox(width: 8),
                                                  Text('BIM'),
                                                ],
                                              ),
                                              value: 'bim',
                                              groupValue: _tipoPago,
                                              activeColor: Colors.blue,
                                              onChanged: (value) {
                                                setModalState(() {
                                                  _tipoPago = value!;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Código de Operación (solo para tarjeta y transferencia)
                                      if (_tipoPago == 'tarjeta' ||
                                          _tipoPago == 'transferencia' ||
                                          _tipoPago == 'yape' ||
                                          _tipoPago == 'plin' ||
                                          _tipoPago == 'bim') ...[
                                        TextField(
                                          controller: _codigoOperacionController,
                                          decoration: InputDecoration(
                                            labelText: _tipoPago == 'tarjeta'
                                                ? 'Código de Autorización'
                                                : 'Código de Operación',
                                            hintText: _tipoPago == 'tarjeta'
                                                ? 'Ingrese el código de autorización'
                                                : 'Ingrese el código de operación',
                                            prefixIcon: Icon(
                                              _tipoPago == 'tarjeta'
                                                  ? Icons.credit_card
                                                  : Icons.receipt_long,
                                              color: Colors.blue,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue, width: 2),
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-zA-Z0-9]')),
                                            LengthLimitingTextInputFormatter(
                                                20),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Total y botones
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'S/ ${_totalVenta.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _carrito.isEmpty ? null : () {
                                  _procesarVenta();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Procesar Venta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Método para procesar la venta
// Método para procesar la venta
  void _procesarVenta() async {
    print('=== INICIANDO PROCESAMIENTO DE VENTA ===');

    // Imprimir estado inicial
    print('Carrito: $_carrito');
    print('Total venta: $_totalVenta');
    print('DNI Cliente: ${_dniClienteController.text}');
    print('Tipo de pago: $_tipoPago');
    print('Código operación: ${_codigoOperacionController.text}');

    // Validaciones
    if (_carrito.isEmpty) {
      print('ERROR: El carrito está vacío');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dniClienteController.text.isEmpty) {
      print('ERROR: DNI del cliente está vacío');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese el DNI del cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (
    (_tipoPago == 'tarjeta' ||
        _tipoPago == 'transferencia' ||
        _tipoPago == 'yape' ||
        _tipoPago == 'plin' ||
        _tipoPago == 'bim') &&
        _codigoOperacionController.text.isEmpty
    ) {
      print('ERROR: Código de operación requerido para tipo de pago: $_tipoPago');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tipoPago == 'tarjeta'
              ? 'Ingrese el código de autorización'
              : 'Ingrese el código de operación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('=== VALIDACIONES PASADAS ===');

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: S/ ${_totalVenta.toStringAsFixed(2)}'),
            Text('DNI Cliente: ${_dniClienteController.text}'),
            Text('Tipo de Pago: ${_tipoPago.toUpperCase()}'),
            if (_tipoPago != 'efectivo')
              Text('Código: ${_codigoOperacionController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    print('Confirmación del usuario: $confirmar');

    if (confirmar == true) {
      try {
        print('=== CREANDO DETALLES DE VENTA ===');

        List<DetalleVenta> detalles = _carrito.entries.map((entry) {
          print('Producto ID: ${entry.key}, Cantidad: ${entry.value}');
          return DetalleVenta(
            idProducto: entry.key,
            cantidad: entry.value,
          );
        }).toList();

        print('Detalles creados: ${detalles.length} elementos');

        Venta nuevaVenta = Venta(
          identificacion: int.parse(_dniClienteController.text).toString(),
          tipoPago: _tipoPago,
          codigoOperacion: _codigoOperacionController.text.isEmpty
              ? null
              : _codigoOperacionController.text,
          detalles: detalles,
        );

        print('=== OBJETO VENTA CREADO ===');
        print('Identificación: ${nuevaVenta.identificacion}');
        print('Tipo de pago: ${nuevaVenta.tipoPago}');
        print('Código operación: ${nuevaVenta.codigoOperacion}');
        print('Número de detalles: ${nuevaVenta.detalles!.length}');

        print('Número de detalles: ${nuevaVenta.detalles?.length ?? 0}');
        for (int i = 0; i < (nuevaVenta.detalles?.length ?? 0); i++) {
          final detalle = nuevaVenta.detalles![i]; // aquí también podrías aplicar verificación adicional
          print('Detalle $i - ID Producto: ${detalle.idProducto}, Cantidad: ${detalle.cantidad}');
        }

        print('=== ENVIANDO VENTA A BASE DE DATOS ===');
        VentaData ventaData = VentaData();
        await ventaData.createVenta(nuevaVenta);
        print('Venta enviada exitosamente');

        // Limpiar el carrito y campos
        setState(() {
          _carrito.clear();
          _totalVenta = 0.0;
        });
        _limpiarCamposVenta();

        await _loadProductos();

        print('=== VENTA COMPLETADA - LIMPIANDO DATOS ===');
        print('Carrito después de limpiar: $_carrito');
        print('Total después de limpiar: $_totalVenta');

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('ERROR AL PROCESAR VENTA: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la venta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Venta cancelada por el usuario');
    }

    print('=== FIN DEL PROCESAMIENTO ===');
  }
}