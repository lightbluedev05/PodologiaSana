import 'package:flutter/material.dart';
import 'package:podologia_sana/views/dashboard_admin/pacientes_view.dart';
import 'package:podologia_sana/views/login_view.dart';
import '../views/dashboard_admin/citas_view.dart';
import '../models/producto_model.dart';
import '../data/producto_data.dart';
import '../views/dashboard_recep/registrar_ventas_view.dart';
import '../app_routes.dart';
import '../views/dashboard_admin/citas_view.dart';
import '../views/dashboard_recep/atencion_pagos.dart';

class RecepcionistaController {
  static final RecepcionistaController _instance = RecepcionistaController._internal();
  factory RecepcionistaController() => _instance;
  RecepcionistaController._internal();

  List<Producto> _productos = [];
  final ProductoData _productoData = ProductoData();

  List<Producto> get productos => _productos;

  void volverAlLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  Future<void> cargarProductos() async {
    try {
      _productos = await _productoData.fetchProductos();
      debugPrint('Productos cargados: ${_productos.length}');
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }
  }

  // Método para abrir la vista de agendar cita
  void abrirAgendarCita(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgendarCitaView(),
      ),
    );
  }

  void abrirProcesarPagos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProcesarPagosView(),
      ),
    );
  }

  // Método para abrir la vista de registrar ventas
  void abrirRegistrarVentas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrarVentasView(),
      ),
    );
  }

  // Método para abrir la vista de pacientes
  void abrirPacientes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PacientesViewxd(),
      ),
    );
  }

  // Método para obtener las opciones del menú (útil para testing o reutilización)
  List<MenuOption> getMenuOptions() {
    return [
      MenuOption(
        title: 'Agendar Cita',
        subtitle: 'Programa una nueva cita médica',
        icon: Icons.calendar_today,
        color: Colors.green,
        action: abrirAgendarCita,
      ),
      MenuOption(
        title: 'Procesar Pagos',
        subtitle: 'Gestionar pagos para atencion',
        icon: Icons.payment,
        color: Colors.orange,
        action: abrirProcesarPagos,
      ),
      MenuOption(
        title: 'Registrar Ventas',
        subtitle: 'Gestionar productos y ventas',
        icon: Icons.shopping_cart,
        color: Colors.purple,
        action: abrirRegistrarVentas,
      ),
      MenuOption(
        title: 'Pacientes',
        subtitle: 'Consultar y gestionar pacientes',
        icon: Icons.people,
        color: Colors.blue,
        action: abrirPacientes,
      ),
    ];
  }

  // Método para validar permisos (para futuras implementaciones)
  bool tienePermiso(String accion) {
    return true;
  }

  // Método para logging de acciones (para auditoría)
  void logAccion(String accion) {
    debugPrint('Recepcionista - Acción: $accion - ${DateTime.now()}');
  }
}

// Clase para definir las opciones del menú
class MenuOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function(BuildContext) action;

  MenuOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
  });
}

// Placeholder classes separadas
class AgendarCitaView extends StatelessWidget {
  const AgendarCitaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        backgroundColor: Colors.green[700],
      ),
      body: const AdminCitasView(),
    );
  }
}

class ProcesarPagosView extends StatelessWidget {
  const ProcesarPagosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesar Pagos'),
        backgroundColor: Colors.orange[700],
      ),
      body: const AtencionPagosView(),
    );
  }
}

class PacientesViewxd extends StatelessWidget {
  const PacientesViewxd({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pacientes'),
        backgroundColor: Colors.blue[700],
      ),
      body: const PacientesView(),
    );
  }
}