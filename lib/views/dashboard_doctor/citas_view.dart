import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/citas_data.dart';
import '../../models/citas_model.dart';
import '../../utils/colors.dart';

class CitasView extends StatefulWidget {
  final String nombreDoctor;

  const CitasView(this.nombreDoctor, {super.key});

  @override
  State<CitasView> createState() => _CitasViewState();
}

class _CitasViewState extends State<CitasView> with TickerProviderStateMixin {
  bool isLoading = true;
  List<Cita> citas = [];
  int cantidadCitasHoy = 0;
  int? hoveredIndex;
  String vistaActual = 'HOY';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadCitasHoy();

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
