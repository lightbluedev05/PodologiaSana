import 'package:flutter/material.dart';
import 'package:podologia_sana/views/login_view.dart';

class RecepcionistaView extends StatefulWidget {
  const RecepcionistaView({super.key});

  @override
  State<RecepcionistaView> createState() => _RecepcionistaViewState();
}

class _RecepcionistaViewState extends State<RecepcionistaView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Aquí defines a dónde debe ir cuando presionas el ícono
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
            );
          },
        ),
        title: const Text(
          'Panel de Recepción',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título principal
                const Text(
                  'Bienvenido al Sistema de Recepción',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecciona una opción para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Opciones principales
                Row(
                  children: [
                    // Opción 1: Agendar Cita
                    Expanded(
                      child: _buildOptionCard(
                        context: context,
                        title: 'Agendar Cita',
                        subtitle: 'Programa una nueva cita médica',
                        icon: Icons.calendar_today,
                        color: Colors.green,
                        onTap: () => _abrirAgendarCita(context),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Opción 2: Procesar Pagos
                    Expanded(
                      child: _buildOptionCard(
                        context: context,
                        title: 'Procesar Pagos',
                        subtitle: 'Gestionar pagos y facturación',
                        icon: Icons.payment,
                        color: Colors.orange,
                        onTap: () => _abrirProcesarPagos(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Tercera opción: Registrar Ventas
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: _buildOptionCard(
                        context: context,
                        title: 'Registrar Ventas',
                        subtitle: 'Gestionar productos y ventas',
                        icon: Icons.shopping_cart,
                        color: Colors.purple,
                        onTap: () => _abrirRegistrarVentas(context),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 40),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Para obtener ayuda adicional, contacta al administrador del sistema.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirAgendarCita(BuildContext context) {
    // Navegar a la pantalla de agendar cita
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgendarCitaView(),
      ),
    );
  }

  void _abrirProcesarPagos(BuildContext context) {
    // Navegar a la pantalla de procesar pagos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProcesarPagosView(),
      ),
    );
  }

  void _abrirRegistrarVentas(BuildContext context) {
    // Navegar a la pantalla de registrar ventas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrarVentasView(),
      ),
    );
  }
}

// Pantalla placeholder para Agendar Cita
class AgendarCitaView extends StatelessWidget {
  const AgendarCitaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        backgroundColor: Colors.green[700],
      ),
      body: const Center(
        child: Text(
          'Pantalla de Agendar Cita\n(Por implementar)',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Pantalla placeholder para Procesar Pagos
class ProcesarPagosView extends StatelessWidget {
  const ProcesarPagosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesar Pagos'),
        backgroundColor: Colors.orange[700],
      ),
      body: const Center(
        child: Text(
          'Pantalla de Procesar Pagos\n(Por implementar)',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Pantalla placeholder para Registrar Ventas
class RegistrarVentasView extends StatelessWidget {
  const RegistrarVentasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ventas'),
        backgroundColor: Colors.purple[700],
      ),
      body: const Center(
        child: Text(
          'Pantalla de Registrar Ventas\n(Por implementar)',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}