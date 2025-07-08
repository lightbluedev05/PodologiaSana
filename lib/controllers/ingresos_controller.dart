import 'package:flutter/material.dart';
import '../../data/atencion_data.dart';
import '../../data/ventas_data.dart';
import '../../models/atencion_model.dart';
import '../../models/ventas_model.dart';

class AtencionIngreso {
  final String nombrePaciente;
  final DateTime fechaAtencion;
  final double totalPago;

  AtencionIngreso({
    required this.nombrePaciente,
    required this.fechaAtencion,
    required this.totalPago,
  });

  factory AtencionIngreso.fromAtencion(Atencion a) {
    return AtencionIngreso(
      nombrePaciente: a.nombrePaciente,
      fechaAtencion: a.fechaAtencion,
      totalPago: double.tryParse(a.total) ?? 0.0,
    );
  }
}

class VentaIngreso {
  final int idVenta;
  final String nombrePaciente;
  final DateTime fechaVenta;
  final List<String> productos;
  final double total;

  VentaIngreso({
    required this.idVenta,
    required this.nombrePaciente,
    required this.fechaVenta,
    required this.productos,
    required this.total,
  });

  factory VentaIngreso.fromVenta(Venta v, List<DetalleVenta> detalles) {
    return VentaIngreso(
      idVenta: v.id!,
      nombrePaciente: v.nombreCliente ?? '${v.nombrePaciente ?? ''} ${v.apellidoPaciente ?? ''}',
      fechaVenta: DateTime.parse(v.fechaVenta),
      productos: detalles.map((d) => d.nombreProducto ?? '').where((p) => p.isNotEmpty).toList(),
      total: v.total,
    );
  }
}

class IngresosController with ChangeNotifier {
  final List<AtencionIngreso> _atenciones = [];
  final List<VentaIngreso> _ventas = [];
  bool _isLoading = false;

  List<AtencionIngreso> get atenciones => _atenciones;
  List<VentaIngreso> get ventas => _ventas;
  bool get isLoading => _isLoading;

  Future<void> fetchIngresos() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Atenciones
      final listaAtenciones = await AtencionData().fetchAllAtencion();
      final atencionesConvertidas = listaAtenciones
          .map((a) => AtencionIngreso.fromAtencion(a))
          .toList();
      _atenciones
        ..clear()
        ..addAll(atencionesConvertidas);

      debugPrint('Atenciones cargadas: ${_atenciones.length}');

      // Ventas
      final ventaData = VentaData();
      int page = 1;
      bool hasMore = true;
      final List<Venta> ventasTotales = [];

      // Paginado
      while (hasMore) {
        final response = await ventaData.fetchVentas(page: page, limit: 50);
        print('Pasa response');

        final List<Venta> ventasPage = response['ventas'];
        ventasTotales.addAll(ventasPage);
        print('Pasa ventasTotales');

        final pagination = response['pagination'];

        final int? currentPage = pagination['page'];
        final int? totalPages = pagination['totalPages'];

        if (currentPage != null && totalPages != null) {
          if (currentPage >= totalPages) {
            hasMore = false;
          } else {
            page++;
          }
        } else {
          debugPrint('⚠️ Valores de paginación inválidos: $pagination');
          hasMore = false; // Sal del bucle si no puedes confiar en los datos
        }
      }

      debugPrint('Ventas cargadas: ${ventasTotales.length}');

      final List<VentaIngreso> ventasConvertidas = [];

      for (final venta in ventasTotales) {
        final detalles = await ventaData.fetchDetallesVenta(venta.id!);
        ventasConvertidas.add(VentaIngreso.fromVenta(venta, detalles));
      }

      _ventas
        ..clear()
        ..addAll(ventasConvertidas);
    } catch (e) {
      debugPrint('Error al cargar ingresos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atenciones
  double get totalAtencionesMesActual {
    final ahora = DateTime.now();
    return _atenciones
        .where((a) =>
    a.fechaAtencion.year == ahora.year &&
        a.fechaAtencion.month == ahora.month)
        .fold(0.0, (sum, a) => sum + a.totalPago);
  }

  double get totalAtencionesMesPasado {
    final ahora = DateTime.now();
    final anterior = DateTime(ahora.year, ahora.month - 1);
    return _atenciones
        .where((a) =>
    a.fechaAtencion.year == anterior.year &&
        a.fechaAtencion.month == anterior.month)
        .fold(0.0, (sum, a) => sum + a.totalPago);
  }

  // Productos
  double get totalVentasMesActual {
    final ahora = DateTime.now();
    return _ventas
        .where((v) =>
    v.fechaVenta.year == ahora.year &&
        v.fechaVenta.month == ahora.month)
        .fold(0.0, (sum, v) => sum + v.total);
  }

  double get totalVentasMesPasado {
    final ahora = DateTime.now();
    final anterior = DateTime(ahora.year, ahora.month - 1);
    return _ventas
        .where((v) =>
    v.fechaVenta.year == anterior.year &&
        v.fechaVenta.month == anterior.month)
        .fold(0.0, (sum, v) => sum + v.total);
  }
}
