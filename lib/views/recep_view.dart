// views/recepcionista_view.dart
import 'package:flutter/material.dart';
import 'package:podologia_sana/controllers/recepcionista_controller.dart';

class RecepcionistaView extends StatefulWidget {
  const RecepcionistaView({super.key});

  @override
  State<RecepcionistaView> createState() => _RecepcionistaViewState();
}

class _RecepcionistaViewState extends State<RecepcionistaView> {
  final RecepcionistaController _controller = RecepcionistaController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _controller.logAccion('Volver al login');
            _controller.volverAlLogin(context);
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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

                  ..._buildMenuOptions(),

                  const SizedBox(height: 40),

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
      ),
    );
  }

  List<Widget> _buildMenuOptions() {
    final options = _controller.getMenuOptions();
    List<Widget> widgets = [];

    // Primera fila: Agendar Cita y Procesar Pagos
    widgets.add(
      Row(
        children: [
          Expanded(
            child: _buildOptionCard(
              option: options[0], // Agendar Cita
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildOptionCard(
              option: options[1], // Procesar Pagos
            ),
          ),
        ],
      ),
    );

    widgets.add(const SizedBox(height: 30));

    // Segunda fila: Registrar Ventas y Pacientes
    widgets.add(
      Row(
        children: [
          Expanded(
            child: _buildOptionCard(
              option: options[2], // Registrar Ventas
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildOptionCard(
              option: options[3], // Pacientes
            ),
          ),
        ],
      ),
    );

    return widgets;
  }

  Widget _buildOptionCard({required MenuOption option}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (_controller.tienePermiso(option.title)) {
            _controller.logAccion('Acceso a ${option.title}');
            option.action(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No tienes permisos para ${option.title}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
                option.color.withOpacity(0.1),
                option.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  option.icon,
                  size: 48,
                  color: option.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                option.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: option.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                option.subtitle,
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
}