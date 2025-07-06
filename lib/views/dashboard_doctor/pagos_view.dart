import 'package:flutter/material.dart';

class PagosView extends StatefulWidget {
  const PagosView({super.key});

  @override
  State<PagosView> createState() => _PagosViewState();
}

class _PagosViewState extends State<PagosView> {
  // Datos de ejemplo - reemplaza con tu fuente de datos real
  final List<AtencionPago> atenciones = [
    AtencionPago(
      nombrePaciente: "María García López",
      fechaAtencion: DateTime(2024, 7, 15),
      totalPago: 150.00,
    ),
    AtencionPago(
      nombrePaciente: "Carlos Rodríguez Vega",
      fechaAtencion: DateTime(2024, 7, 18),
      totalPago: 200.00,
    ),
    AtencionPago(
      nombrePaciente: "Ana Martínez Silva",
      fechaAtencion: DateTime(2024, 6, 22),
      totalPago: 175.50,
    ),
    AtencionPago(
      nombrePaciente: "Luis Fernando Castro",
      fechaAtencion: DateTime(2024, 7, 25),
      totalPago: 300.00,
    ),
    AtencionPago(
      nombrePaciente: "Isabel Morales Ruiz",
      fechaAtencion: DateTime(2024, 7, 28),
      totalPago: 125.00,
    ),    AtencionPago(
      nombrePaciente: "María García López",
      fechaAtencion: DateTime(2024, 7, 15),
      totalPago: 150.00,
    ),
    AtencionPago(
      nombrePaciente: "Carlos Rodríguez Vega",
      fechaAtencion: DateTime(2024, 7, 18),
      totalPago: 200.00,
    ),
    AtencionPago(
      nombrePaciente: "Ana Martínez Silva",
      fechaAtencion: DateTime(2024, 6, 22),
      totalPago: 175.50,
    ),
    AtencionPago(
      nombrePaciente: "Luis Fernando Castro",
      fechaAtencion: DateTime(2024, 7, 25),
      totalPago: 300.00,
    ),
    AtencionPago(
      nombrePaciente: "Isabel Morales Ruiz",
      fechaAtencion: DateTime(2024, 7, 28),
      totalPago: 125.00,
    ),    AtencionPago(
      nombrePaciente: "María García López",
      fechaAtencion: DateTime(2024, 7, 15),
      totalPago: 150.00,
    ),
    AtencionPago(
      nombrePaciente: "Carlos Rodríguez Vega",
      fechaAtencion: DateTime(2024, 7, 18),
      totalPago: 200.00,
    ),
    AtencionPago(
      nombrePaciente: "Ana Martínez Silva",
      fechaAtencion: DateTime(2024, 6, 22),
      totalPago: 175.50,
    ),
    AtencionPago(
      nombrePaciente: "Luis Fernando Castro",
      fechaAtencion: DateTime(2024, 7, 25),
      totalPago: 300.00,
    ),
    AtencionPago(
      nombrePaciente: "Isabel Morales Ruiz",
      fechaAtencion: DateTime(2024, 7, 28),
      totalPago: 125.00,
    ),    AtencionPago(
      nombrePaciente: "María García López",
      fechaAtencion: DateTime(2024, 7, 15),
      totalPago: 150.00,
    ),
    AtencionPago(
      nombrePaciente: "Carlos Rodríguez Vega",
      fechaAtencion: DateTime(2024, 7, 18),
      totalPago: 200.00,
    ),
    AtencionPago(
      nombrePaciente: "Ana Martínez Silva",
      fechaAtencion: DateTime(2024, 6, 22),
      totalPago: 175.50,
    ),
    AtencionPago(
      nombrePaciente: "Luis Fernando Castro",
      fechaAtencion: DateTime(2024, 7, 25),
      totalPago: 300.00,
    ),
    AtencionPago(
      nombrePaciente: "Isabel Morales Ruiz",
      fechaAtencion: DateTime(2024, 7, 28),
      totalPago: 125.00,
    ),
  ];

  double get totalRecaudado {
    return atenciones
        .fold(0.0, (sum, atencion) => sum + atencion.totalPago);
  }

  double get totalMesActual {
    final ahora = DateTime.now();
    return atenciones
        .where((atencion) =>
    atencion.fechaAtencion.year == ahora.year &&
        atencion.fechaAtencion.month == ahora.month)
        .fold(0.0, (sum, atencion) => sum + atencion.totalPago);
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

          // Lista de atenciones
          Expanded(
            child: ListView.builder(
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
                    // Monto total - con énfasis especial
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

// Modelo de datos para las atenciones
class AtencionPago {
  final String nombrePaciente;
  final DateTime fechaAtencion;
  final double totalPago;

  AtencionPago({
    required this.nombrePaciente,
    required this.fechaAtencion,
    required this.totalPago,
  });
}