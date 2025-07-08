import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/citas_data.dart';
import '../../data/atencion_data.dart';
import '../../models/citas_model.dart';
import '../../models/doctor_model.dart';
import '../../data/doctor_data.dart';
import '../../models/paciente_model.dart';
import '../../data/paciente_data.dart';

class AtencionPagosView extends StatefulWidget {
  const AtencionPagosView({super.key});

  @override
  State<AtencionPagosView> createState() => _AtencionPagosViewState();
}

class _AtencionPagosViewState extends State<AtencionPagosView> {
  bool isLoading = true;
  List<Cita> citasHoy = [];
  final DoctorData _data = DoctorData();
  final AtencionData _atencionData = AtencionData();
  List<Doctor> doctores = [];
  Map<int, String> mapaDoctores = {};
  final PacienteData _dataPA = PacienteData();
  List<Paciente> pacientes = [];
  Map<String, int> mapaPacientes = {};
  @override
  void initState() {
    super.initState();
    _loadCitasHoy();
    _loadDoctores();
    _loadPacientes();
  }

  Future<void> _loadCitasHoy() async {
    setState(() {
      isLoading = true;
    });

    try {
      final DateTime hoy = DateTime.now();
      final result = await CitaData().fetchCitasPorFecha(hoy);
      setState(() {
        citasHoy = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener citas de hoy: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las citas de hoy'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadDoctores() async {
    try {
      final result = await _data.fetchDoctores();
      setState(() {
        doctores = result;
        mapaDoctores = {
          for (var d in result) d.id: '${d.nombre} ${d.apellido}'
        };
      });
    } catch (e) {
      print('Error al cargar doctores: $e');
    }
  }
  Future<void> _loadPacientes() async {
    print('⏳ Iniciando carga de pacientes...');

    try {
      final result = await _dataPA.fetchPacientes();

      print('✅ Pacientes recibidos: ${result.length}');
      for (var p in result) {
        print('🧍 Paciente: id=${p.id_paciente}, nombre=${p.paciente}');
      }

      if (!mounted) {
        print('⚠️ El widget ya no está montado, se cancela setState');
        return;
      }

      setState(() {
        pacientes = result;
        mapaPacientes = {
          for (var p in result)
            p.paciente: p.id_paciente
        };
        print("------------------------------------------------");
        print(mapaPacientes);
        print("------------------------------------------------");
      });

      print('🎯 Pacientes cargados y mapeados exitosamente');
    } catch (e, stackTrace) {
      print('❌ Error al cargar pacientes: $e');
      print('🔍 StackTrace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar la lista de pacientes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(String hora) {
    return hora.substring(0, 5);
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFF39C12);
      case 'realizada':
        return const Color(0xFF2ECC71);
      case 'cancelada':
        return const Color(0xFFE74C3C);
      case 'reprogramada':
        return const Color(0xFF9B59B6);
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoBackgroundColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFF39C12).withOpacity(0.1);
      case 'realizada':
        return const Color(0xFF2ECC71).withOpacity(0.1);
      case 'cancelada':
        return const Color(0xFFE74C3C).withOpacity(0.1);
      case 'reprogramada':
        return const Color(0xFF9B59B6).withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consultorio':
        return const Color(0xFF3498DB).withOpacity(0.1);
      case 'domicilio':
        return const Color(0xFF2ECC71).withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTipoTextColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consultorio':
        return const Color(0xFF3498DB);
      case 'domicilio':
        return const Color(0xFF2ECC71);
      default:
        return Colors.grey;
    }
  }

  void _mostrarModalPago(Cita cita) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PagoDialog(
          cita: cita,
          doctores: doctores,
          pacientes: pacientes,
          onPagoCompletado: () {
            _loadCitasHoy(); // Recargar las citas
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();

    return Scaffold(
      body: Container(
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
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atención y Pagos',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Citas de hoy - ${_formatearFecha(hoy)} (${citasHoy.length} citas)',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.today,
                    color: Color(0xFF3498DB),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Lista de citas
            Expanded(
              child: citasHoy.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No hay citas programadas para hoy',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Las citas aparecerán aquí cuando estén programadas',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: citasHoy.length,
                itemBuilder: (context, index) {
                  final cita = citasHoy[index];
                  return InkWell(
                    onTap: () => _mostrarModalPago(cita),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar del paciente
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3498DB).withOpacity(0.1),
                                  const Color(0xFF2980B9).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF3498DB),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Información de la cita
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre del paciente y estado
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cita.paciente,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getEstadoBackgroundColor(cita.estado),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        cita.estado.toUpperCase(),
                                        style: GoogleFonts.roboto(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _getEstadoColor(cita.estado),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Doctor
                                Row(
                                  children: [
                                    Icon(
                                      Icons.medical_services,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Dr. ${cita.doctor}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Motivo
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cita.motivo,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Hora y tipo
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatearHora(cita.hora),
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getTipoColor(cita.tipo),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        cita.tipo.toUpperCase(),
                                        style: GoogleFonts.roboto(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _getTipoTextColor(cita.tipo),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Icono de flecha para indicar que es clickeable
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PagoDialog extends StatefulWidget {
  final Cita cita;
  final List<Doctor> doctores;
  final List<Paciente> pacientes;
  final VoidCallback onPagoCompletado;

  const _PagoDialog({
    required this.cita,
    required this.doctores,
    required this.pacientes,
    required this.onPagoCompletado,
  });

  @override
  State<_PagoDialog> createState() => _PagoDialogState();
}

class _PagoDialogState extends State<_PagoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _totalController = TextEditingController();
  final _codigoOperacionController = TextEditingController();
  final _direccionController = TextEditingController();

  int _tipoPagoSeleccionado = 1;
  bool _isProcessing = false;
  int _currentStep = 0;

  final List<String> _tiposPago = ['Efectivo', 'Transferencia', 'Tarjeta','Yape', 'Plin', 'Blim'];

  @override
  void initState() {
    super.initState();
    if (widget.cita.tipo.toLowerCase() == 'domicilio') {
      _direccionController.text = '';
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _codigoOperacionController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Buscar el doctor por nombre
      final doctor = widget.doctores.firstWhere(
            (d) => '${d.nombre} ${d.apellido}' == widget.cita.doctor,
        orElse: () => widget.doctores.first,
      );

      final paciente = widget.pacientes.firstWhere(
        (p) => p.paciente == widget.cita.paciente,
        orElse: () => widget.pacientes.first,
      );

      String tipo_pago_String = "";
      switch (_tipoPagoSeleccionado) {
        case 1:
          tipo_pago_String = "efectivo";
          break;
        case 2:
          tipo_pago_String = "transferencia";
          break;
        case 3:
          tipo_pago_String = "tarjeta";
          break;
        case 4:
          tipo_pago_String = "yape";
          break;
        case 5:
          tipo_pago_String = "plin";
          break;
        case 6:
          tipo_pago_String = "blim";
          break;
        default:
          tipo_pago_String = "efectivo"; // Por defecto
      }

      final success = await AtencionData().crearAtencion(
        idPaciente: paciente.identificacion,
        idHistorial: 4,
        idAtencion: widget.cita.id,
        tipoAtencion: widget.cita.tipo.toLowerCase() == 'consultorio' ? "consultorio" : "domicilio",
        consultorio: widget.cita.tipo.toLowerCase() == 'consultorio' ? 1 : null,
        direccionDomicilio: widget.cita.tipo.toLowerCase() == 'domicilio'
            ? _direccionController.text
            : null,
        fechaAtencion: DateTime.now(),
        idDoctor: doctor.identificacion,
        diagnostico: null,
        observaciones: null,
        peso: null,
        altura: null,
        total: _totalController.text,
        idTipoPago: tipo_pago_String,
        codigoOperacion: _tipoPagoSeleccionado == 2 && _codigoOperacionController.text.isNotEmpty
            ? _codigoOperacionController.text
            : null,
      );

      if (success) {
        Navigator.of(context).pop();
        widget.onPagoCompletado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atención creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la atención'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error al procesar pago: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el pago'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDatosCita();
      case 1:
        return _buildDatosPago();
      default:
        return Container();
    }
  }

  Widget _buildDatosCita() {
    return Column(
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
        const SizedBox(height: 20),

        _buildInfoRow('Paciente', widget.cita.paciente),
        _buildInfoRow('Doctor', 'Dr. ${widget.cita.doctor}'),
        _buildInfoRow('Motivo', widget.cita.motivo),
        _buildInfoRow('Tipo', widget.cita.tipo.toUpperCase()),
        _buildInfoRow('Fecha', widget.cita.fecha),
        _buildInfoRow('Hora', widget.cita.hora),

        if (widget.cita.tipo.toLowerCase() == 'domicilio') ...[
          const SizedBox(height: 20),
          TextFormField(
            controller: _direccionController,
            decoration: InputDecoration(
              labelText: 'Dirección de domicilio',
              hintText: 'Ingrese la dirección completa',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
            validator: (value) {
              if (widget.cita.tipo.toLowerCase() == 'domicilio' &&
                  (value == null || value.trim().isEmpty)) {
                return 'La dirección es requerida para atenciones a domicilio';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDatosPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Pago',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _totalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Total a pagar',
            hintText: 'Ej: 50.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: 'S/.',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El total es requerido';
            }
            if (double.tryParse(value) == null) {
              return 'Ingrese un valor numérico válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        Text(
          'Tipo de Pago',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 10),

        ...List.generate(_tiposPago.length, (index) {
          return RadioListTile<int>(
            title: Text(_tiposPago[index]),
            value: index + 1,
            groupValue: _tipoPagoSeleccionado,
            onChanged: (value) {
              setState(() {
                _tipoPagoSeleccionado = value!;
              });
            },
          );
        }),

        if (_tipoPagoSeleccionado != 1) ...[
          const SizedBox(height: 15),
          TextFormField(
            controller: _codigoOperacionController,
            decoration: InputDecoration(
              labelText: 'Código de operación',
              hintText: 'Ingrese el código de la transferencia',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.receipt),
            ),
            validator: (value) {
              if (_tipoPagoSeleccionado == 2 &&
                  (value == null || value.trim().isEmpty)) {
                return 'El código de operación es requerido';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Proceso de Atención',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Indicador de pasos
              Row(
                children: [
                  _buildStepIndicator(0, 'Datos de Cita'),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > 0 ? const Color(0xFF3498DB) : Colors.grey[300],
                    ),
                  ),
                  _buildStepIndicator(1, 'Pago'),
                ],
              ),
              const SizedBox(height: 30),

              // Contenido del paso actual
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),

              // Botones de navegación
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: const Text('Anterior'),
                    )
                  else
                    const SizedBox(),

                  ElevatedButton(
                    onPressed: _isProcessing ? null : () {
                      if (_currentStep == 0) {
                        _nextStep();
                      } else {
                        _procesarPago();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 0
                          ? const Color(0xFF3498DB)
                          : const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),child: _isProcessing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    _currentStep == 0 ? 'Siguiente' : 'Completar Atención',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep >= stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3498DB) : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF3498DB) : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}