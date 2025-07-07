import 'package:flutter/material.dart';
import '../../data/atencion_data.dart';
import '../../models/atencion_model.dart';

class PagosView extends StatefulWidget {
  final String nombreDoctor;
  final int idDoctor;

  const PagosView(this.nombreDoctor, {super.key, required this.idDoctor});

  @override
  State<PagosView> createState() => _PagosViewState();
}

class _PagosViewState extends State<PagosView> {
  final List<AtencionPago> atenciones = [];
  bool isLoading = true; // Estado de carga

  @override
  void initState() {
    super.initState();
    fetchAtenciones();
  }

  Future<void> fetchAtenciones() async {
    setState(() {
      isLoading = true;
    });

    try {
      final lista = await AtencionData().fetchAtencionesPorDoctor(widget.idDoctor);
      final listaConvertida = lista.map((a) => AtencionPago.fromAtencion(a)).toList();

      // DEBUG: Mostrar fechas
      final ahora = DateTime.now();
      print('Fecha actual: $ahora');
      for (var a in listaConvertida) {
        print('Fecha atención: ${a.fechaAtencion}');
      }

      setState(() {
        atenciones.clear();
        atenciones.addAll(listaConvertida);
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar atenciones: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double get totalRecaudado {
    return atenciones.fold(0.0, (sum, a) => sum + a.totalPago);
  }

  double get totalMesActual {
    final ahora = DateTime.now();
    return atenciones
        .where((a) =>
    a.fechaAtencion.year == ahora.year &&
        a.fechaAtencion.month == ahora.month)
        .fold(0.0, (sum, a) => sum + a.totalPago);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Registro de Pagos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Recaudado',
                        'S/. ${totalRecaudado.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.attach_money,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Total del Mes',
                        'S/. ${totalMesActual.toStringAsFixed(2)}',
                        Colors.blue,
                        Icons.calendar_month,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de atenciones o indicador de carga
          Expanded(
            child: isLoading
                ? _buildLoadingWidget()
                : atenciones.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: atenciones.length,
              itemBuilder: (context, index) {
                final atencion = atenciones[index];
                return _buildAtencionCard(atencion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando registros de pagos...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor espera un momento',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros de pagos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los pagos aparecerán aquí cuando se registren',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtencionCard(AtencionPago atencion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atencion.nombrePaciente,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(atencion.fechaAtencion),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        'S/. ${atencion.totalPago.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class AtencionPago {
  final String nombrePaciente;
  final DateTime fechaAtencion;
  final double totalPago;

  AtencionPago({
    required this.nombrePaciente,
    required this.fechaAtencion,
    required this.totalPago,
  });

  factory AtencionPago.fromAtencion(Atencion a) {
    return AtencionPago(
      nombrePaciente: a.nombrePaciente,
      fechaAtencion: a.fechaAtencion,
      totalPago: double.tryParse(a.total) ?? 0.0,
    );
  }
}