import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/atencion_data.dart';
import '../../models/atencion_model.dart';

class AtencionPacienteView extends StatefulWidget {
  final String nombrePaciente;
  final String motivoCita;
  final String fechaCita;
  final String horaCita;
  final String nombreDoctor;
  final List<Atencion> historial;

  const AtencionPacienteView({
    super.key,
    required this.nombrePaciente,
    required this.motivoCita,
    required this.fechaCita,
    required this.horaCita,
    required this.nombreDoctor,
    required this.historial,
  });

  @override
  State<AtencionPacienteView> createState() => _AtencionPacienteViewState();
}

class _AtencionPacienteViewState extends State<AtencionPacienteView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isHistorialVisible = false;
  final Atencion _atencion = Atencion.vacio();

  // Controllers para los campos del formulario
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _diagnosticoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _toggleHistorial() {
    setState(() {
      _isHistorialVisible = !_isHistorialVisible;
      if (_isHistorialVisible) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  void _guardarAtencion() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: Aquí implementar la lógica para guardar la atención
      // Por ejemplo, enviar datos a una API o base de datos

      print('Guardando atención:');
      print('Paciente: ${widget.nombrePaciente}');
      print('Total: ${_atencion.total}');
      print('Peso: ${_atencion.peso}');
      print('Altura: ${_atencion.altura}');
      print('Dirección: ${_atencion.direccionDomicilio}');
      print('Código Operación: ${_atencion.codigoOperacion}');
      print('Diagnóstico: ${_atencion.diagnostico}');
      print('Observaciones: ${_atencion.observaciones}');
      print('Tipo Atención: ${_atencion.nombreTipoAtencion}');
      print('Tipo Pago: ${_atencion.nombreTipoPago}');

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  Widget _buildCustomAppBar() {
    return Container(
      height: kToolbarHeight,
      color: const Color(0xFF3498DB),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const BackButton(color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Atención del Paciente',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isHistorialVisible ? Icons.history_toggle_off : Icons.history,
              color: Colors.white,
            ),
            onPressed: _toggleHistorial,
            tooltip: 'Ver Historial',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [

          Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: _isHistorialVisible ? 400 : 0,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCita(),
                        const SizedBox(height: 20),
                        _buildFormularioAtencion(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isHistorialVisible)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildHistorialPanel(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCita() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF3498DB),
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la Cita',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Datos del paciente y la cita programada',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Paciente:', widget.nombrePaciente, Icons.person),
          const SizedBox(height: 10),
          _buildInfoRow('Motivo:', widget.motivoCita, Icons.assignment),
          const SizedBox(height: 10),
          _buildInfoRow('Fecha:', widget.fechaCita, Icons.calendar_today),
          const SizedBox(height: 10),
          _buildInfoRow('Hora:', widget.horaCita, Icons.access_time),
          const SizedBox(height: 10),
          _buildInfoRow('Doctor:', widget.nombreDoctor, Icons.local_hospital),
        ],
      ),
    );
  }

  Widget _buildFormularioAtencion() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos de la Atención',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),

            // Fila: Peso y Altura
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _pesoController,
                    label: 'Peso (kg)',
                    icon: Icons.monitor_weight,
                    onSaved: (value) => _atencion.peso = value ?? '',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextFormField(
                    controller: _alturaController,
                    label: 'Altura (m)',
                    icon: Icons.height,
                    onSaved: (value) => _atencion.altura = value ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Diagnóstico
            _buildTextFormField(
              controller: _diagnosticoController,
              label: 'Diagnóstico',
              icon: Icons.local_hospital,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Ingrese el diagnóstico';
                }
                return null;
              },
              onSaved: (value) => _atencion.diagnostico = value ?? '',
            ),
            const SizedBox(height: 15),

            // Observaciones
            _buildTextFormField(
              controller: _observacionesController,
              label: 'Observaciones',
              icon: Icons.note,
              maxLines: 4,
              onSaved: (value) => _atencion.observaciones = value ?? '',
            ),
            const SizedBox(height: 30),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarAtencion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Guardar Atención',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildHistorialPanel() {

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del panel
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF3498DB),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de Atenciones',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.nombrePaciente,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _toggleHistorial,
                ),
              ],
            ),
          ),

          // Lista de atenciones
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: widget.historial.length,
              itemBuilder: (context, index) {
                return _buildHistorialCard(widget.historial[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialCard(Atencion atencion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(15),
        title: Text(
          atencion.nombreTipoAtencion,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          atencion.fechaAtencion.toString(),
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.medical_services,
            color: Color(0xFF3498DB),
            size: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHistorialInfo('Motivo:', atencion.motivo ?? ''),
                _buildHistorialInfo('Diagnóstico:', atencion.diagnostico ?? ''),
                _buildHistorialInfo('Observaciones:', atencion.observaciones ?? ''),
                _buildHistorialInfo('Peso:', atencion.peso ?? ''),
                _buildHistorialInfo('Altura:', atencion.altura ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF3498DB)),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3498DB)),
        ),
      ),
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }
}