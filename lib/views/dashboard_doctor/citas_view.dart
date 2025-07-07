import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/citas_data.dart';
import '../../models/citas_model.dart';
import 'Atencion_Doctor_view.dart';
import '../../data/atencion_data.dart';
import '../../models/atencion_model.dart';


class CitasView extends StatefulWidget {
  final String nombreDoctor;
  final int idDoctor;

  const CitasView(this.nombreDoctor, {super.key, required this.idDoctor});

  @override
  State<CitasView> createState() => _CitasViewState();
}

class _CitasViewState extends State<CitasView> with TickerProviderStateMixin {
  bool isLoading = true;
  List<Cita> citas = [];
  List<Atencion> atencionesDelPaciente = [];
  int cantidadCitasHoy = 0;
  int? hoveredIndex;
  String vistaActual = 'HOY';
  Cita? citaSeleccionada;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadCitasHoy();
    //_probarAtenciones();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }


  Future<void> _loadCitasHoy() async {
    setState(() {
      isLoading = true;
      vistaActual = 'HOY';
    });
    try {
      final result = await CitaData().fetchCitasHoy(widget.nombreDoctor);
      final cantidad = await CitaData().contarCitasHoy(widget.nombreDoctor);
      setState(() {
        citas = result;
        cantidadCitasHoy = cantidad;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener citas: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _cargarAtencionesDePaciente(String NombrePaciente) async {
    try {
      final result = await AtencionData().fetchAtencionesPorPaciente(NombrePaciente);
      setState(() {
        atencionesDelPaciente = result;
      });
    } catch (e) {
      print('Error cargando atenciones del paciente: $e');
    }
  }

  Future<void> _loadCitas() async {
    setState(() {
      isLoading = true;
      vistaActual = 'PROGRAMADAS';
    });
    try {
      final result = await CitaData().fetchCitasPorDoctor(widget.nombreDoctor);
      setState(() {
        citas = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener citas: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCitasRealizadas() async {
    setState(() {
      isLoading = true;
      vistaActual = 'HISTORIAL';
    });
    try {
      final result = await CitaData().fetchCitasRealizadas(widget.nombreDoctor);
      setState(() {
        citas = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener citas: $e');
      setState(() => isLoading = false);
    }
  }

  void onCitaTap(Cita cita) {
    print('Cita tocada: ${cita.paciente}');
    citaSeleccionada = cita; // GUARDAR la cita seleccionada
    _mostrarHistorialPaciente(cita.paciente);
  }

  void _mostrarHistorialPaciente(String nombrePaciente) async {
    // Muestra diálogo de carga mejorado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando historial médico...',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Obteniendo atenciones de $nombrePaciente',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Espera hasta que se carguen las atenciones
      await _cargarAtencionesDePaciente(nombrePaciente);
    } catch (e) {
      // Manejo de errores
      print('Error cargando atenciones: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga

        // Muestra mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error al cargar el historial: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return; // Sale de la función si hay error
    }

    // Cierra el diálogo de carga solo si el context sigue siendo válido
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header del modal
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_search,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historial de Atenciones',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Paciente: $nombrePaciente',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botón para ir a otra página
                          ElevatedButton(
                            onPressed: () {
                              if (citaSeleccionada != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AtencionPacienteView(
                                      nombrePaciente: citaSeleccionada!.paciente,
                                      motivoCita: citaSeleccionada!.motivo,
                                      fechaCita: citaSeleccionada!.fecha,
                                      horaCita: citaSeleccionada!.hora,
                                      nombreDoctor: widget.nombreDoctor,
                                      historial: atencionesDelPaciente,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3498DB),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_forward, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Continuar',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 24),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contenido del modal
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${atencionesDelPaciente.length} atenciones registradas',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: atencionesDelPaciente.length,
                            itemBuilder: (context, index) {
                              final atencion = atencionesDelPaciente[index];
                              return _buildAtencionCard(atencion, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAtencionCard(Atencion atencion, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la atención
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atencion.nombreTipoAtencion,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            '${atencion.fechaAtencion.day.toString().padLeft(2, '0')}/${atencion.fechaAtencion.month.toString().padLeft(2, '0')}/${atencion.fechaAtencion.year}',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la atención
// Contenido de la atención
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Motivo:', atencion.motivo ?? '', Icons.assignment),
                const SizedBox(height: 15),
                _buildInfoRow('Diagnóstico:', atencion.diagnostico ?? '', Icons.local_hospital),
                const SizedBox(height: 15),
                _buildInfoRow('Observaciones:', atencion.observaciones ?? '', Icons.note),
                const SizedBox(height: 20),

                // Datos físicos y dirección
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos Físicos y Domicilio',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDataChip('Peso', atencion.peso ?? '', Icons.monitor_weight),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDataChip('Altura', atencion.altura ?? '', Icons.height),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('Dirección:', atencion.direccionDomicilio ?? '', Icons.home),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF3498DB)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3498DB)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 25),
          Expanded(
            child: citas.isEmpty
                ? const Center(child: Text("No hay citas registradas."))
                : ListView.builder(
              itemCount: citas.length,
              itemBuilder: (context, index) {
                return _buildCitaCard(context, citas[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, VoidCallback onPressed, {bool showBadge = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (showBadge && cantidadCitasHoy > 0) ...[
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cantidadCitasHoy.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Citas',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${citas.length} citas encontradas',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildFilterButton("HOY", _loadCitasHoy, showBadge: true),
            const SizedBox(width: 10),
            _buildFilterButton("HISTORIAL", _loadCitasRealizadas),
            const SizedBox(width: 10),
            _buildFilterButton("PROGRAMADAS", _loadCitas),
          ],
        ),
      ],
    );
  }

  Widget _buildCitaCard(BuildContext context, Cita cita, int index) {
    bool isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          if (vistaActual == 'HOY') {
            onCitaTap(cita);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(isHovered ? 1.1 : 1.0),
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFFF1F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(isHovered ? 0.15 : 0.08),
                spreadRadius: isHovered ? 3 : 1,
                blurRadius: isHovered ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.1),
                      const Color(0xFF2980B9).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Color(0xFF3498DB), size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cita.paciente,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cita.motivo,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          '${cita.fecha} - ${cita.hora}',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}