import 'package:flutter/material.dart';
import '../../controllers/ingresos_controller.dart';

class IngresosView extends StatefulWidget {
  const IngresosView({super.key});

  @override
  State<IngresosView> createState() => _IngresosViewState();
}

class _IngresosViewState extends State<IngresosView> {
  bool verAtenciones = true;
  final IngresosController _controller = IngresosController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await _controller.fetchIngresos();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double ingresoAtencionesMesActual = _controller.totalAtencionesMesActual;
    double ingresoAtencionesMesPasado = _controller.totalAtencionesMesPasado;
    double ingresosProductosMesActual = _controller.totalVentasMesActual;
    double ingresosProductosMesPasado = _controller.totalVentasMesPasado;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        // Botones superiores
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => verAtenciones = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  verAtenciones ? Colors.blue : Colors.grey.shade300,
                ),
                child: const Text('Ingresos por Atenciones'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => setState(() => verAtenciones = false),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  !verAtenciones ? Colors.blue : Colors.grey.shade300,
                ),
                child: const Text('Ingresos por Productos'),
              ),
            ],
          ),
        ),

        // Resumen
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildResumenCard(
                  'Mes Actual',
                  verAtenciones
                      ? ingresoAtencionesMesActual
                      : ingresosProductosMesActual,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResumenCard(
                  'Mes Pasado',
                  verAtenciones
                      ? ingresoAtencionesMesPasado
                      : ingresosProductosMesPasado,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Desglose
        Expanded(
          child: verAtenciones
              ? _buildListaAtenciones()
              : _buildListaProductos(),
        ),
      ],
    );
  }

  Widget _buildResumenCard(String titulo, double monto) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'S/. ${monto.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaAtenciones() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.atenciones.length,
      itemBuilder: (context, index) {
        final a = _controller.atenciones[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.healing),
            title: Text(a.nombrePaciente),
            subtitle: Text('Fecha: ${_formatDate(a.fechaAtencion)}'),
            trailing: Text(
              'S/. ${a.totalPago.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaProductos() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.ventas.length,
      itemBuilder: (context, index) {
        final v = _controller.ventas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(v.nombrePaciente),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Productos: ${v.productos.isNotEmpty ? v.productos.join(', ') : "Sin detalles"}'),
                Text('Fecha: ${_formatDate(v.fechaVenta)}'),
              ],
            ),
            trailing: Text(
              'S/. ${v.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
