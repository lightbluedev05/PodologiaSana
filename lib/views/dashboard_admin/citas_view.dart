import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/citas_data.dart';
import '../../models/citas_model.dart';
import '../../models/doctor_model.dart';
import '../../data/doctor_data.dart';
import '../../models/paciente_model.dart';
import '../../data/paciente_data.dart';

class AdminCitasView extends StatefulWidget {
  const AdminCitasView({super.key});

  @override
  State<AdminCitasView> createState() => _AdminCitasViewState();
}

class _AdminCitasViewState extends State<AdminCitasView> {
  bool isLoading = true;
  List<Cita> citas = [];
  List<Cita> citasOriginales = [];
  bool _filtroActivo = false;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  final DoctorData _data = DoctorData();
  List<Doctor> doctores = [];
  Map<int, String> mapaDoctores = {};
  Map<int, String> mapaDoctoresIDENTI = {};
  final PacienteData _dataPA = PacienteData();
  List<Paciente> pacientes = [];
  Map<int, String> mapaPacientes = {};

  @override
  void initState() {
    super.initState();
    _loadAllCitas();
    _loadDoctores();
    _loadPacientes();
  }

  Future<void> _loadAllCitas() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await CitaData().fetchAllCitas();
      setState(() {
        citas = result;
        citasOriginales = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener citas: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las citas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadDoctores() async {
    print('⏳ Iniciando carga de doctores...');

    try {
      final result = await _data.fetchDoctores();

      print('✅ Doctores recibidos: ${result.length}');
      for (var d in result) {
        print('👨‍⚕️ Doctor: id=${d.id}, nombre=${d.nombre}, apellido=${d.apellido}');
      }

      if (!mounted) {
        print('⚠️ El widget ya no está montado, se cancela setState');
        return;
      }

      setState(() {
        doctores = result;
        mapaDoctores = {
          for (var d in result)
            d.id: '${d.nombre ?? "[sin nombre]"} ${d.apellido ?? "[sin apellido]"}'
        };
        mapaDoctoresIDENTI = {
          for (var d in result)
            d.id: '${d.identificacion}'
        };
      });

      print('🎯 Doctores cargados y mapeados exitosamente');
    } catch (e, stackTrace) {
      print('❌ Error al cargar doctores: $e');
      print('🔍 StackTrace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar la lista de doctores'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            p.id_paciente: p.paciente ?? '[Sin nombre]'
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

  // NUEVA FUNCIÓN PARA CREAR CITA
  void crearNuevaCita() async {
    // Variables para el formulario
    int? pacienteSeleccionadoId;
    int? doctorSeleccionadoId;
    String identificacionPaciente = '';
    String identificacionDoctor = '';

    String? id_paciente;
    String? id_doctor;

    String motivo = '';
    DateTime? fechaSeleccionada;
    TimeOfDay? horaSeleccionada;
    int tipoSeleccionado = 8; // Default: Consultorio

    final TextEditingController motivoController = TextEditingController();
    final TextEditingController identificacionPacienteController = TextEditingController();
    final TextEditingController identificacionDoctorController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2ECC71).withOpacity(0.1),
                      const Color(0xFF27AE60).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Color(0xFF2ECC71), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Crear Nueva Cita',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Información del Paciente', [
                    // Identificación del paciente
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.badge, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Identificación del Paciente',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: identificacionPacienteController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            hintText: 'Ingrese la identificación del paciente',
                          ),
                          onChanged: (valor) {
                            identificacionPaciente = valor;
                          },
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Información Médica', [
                    // Identificación del doctor
                    const SizedBox(height: 10),
                    // Doctor
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Doctor',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: doctorSeleccionadoId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            hintText: 'Seleccione un doctor',
                          ),
                          items: doctores.map((doctor) {
                            return DropdownMenuItem<int>(
                              value: doctor.id,
                              child: Text('Dr. ${doctor.nombre} ${doctor.apellido}'),
                            );
                          }).toList(),
                          onChanged: (nuevoId) {
                            setDialogState(() {
                              doctorSeleccionadoId = nuevoId;
                              id_doctor = mapaDoctoresIDENTI[nuevoId.toString()];
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Motivo
                    TextField(
                      controller: motivoController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Motivo de la cita',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Ingrese el motivo de la consulta',
                      ),
                      onChanged: (valor) => motivo = valor,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Detalles de la Cita', [
                    // Tipo de cita
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.category, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tipo de Cita',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: tipoSeleccionado,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 8, child: Text('Consultorio')),
                            DropdownMenuItem(value: 9, child: Text('Domicilio')),
                          ],
                          onChanged: (valor) {
                            setDialogState(() {
                              tipoSeleccionado = valor!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Fecha
                    GestureDetector(
                      onTap: () async {
                        final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: tomorrow,
                          firstDate: tomorrow,
                          lastDate: DateTime(2100),
                          locale: const Locale('es', 'ES'),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF2ECC71),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            fechaSeleccionada = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fechaSeleccionada != null
                                    ? '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/${fechaSeleccionada!.month.toString().padLeft(2, '0')}/${fechaSeleccionada!.year}'
                                    : 'Seleccionar fecha',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: fechaSeleccionada != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Hora
                    GestureDetector(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF2ECC71),
                                  onPrimary: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            horaSeleccionada = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                horaSeleccionada != null
                                    ? '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}'
                                    : 'Seleccionar hora',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: horaSeleccionada != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: Text('Cancelar', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton.icon(
              onPressed: () {
// Formatear solo la fecha (ejemplo: "2025-07-08")
                final String fechaFormateada = '${fechaSeleccionada!.year.toString().padLeft(4, '0')}-'
                    '${fechaSeleccionada!.month.toString().padLeft(2, '0')}-'
                    '${fechaSeleccionada!.day.toString().padLeft(2, '0')}';

// Formatear solo la hora (ejemplo: "14:30")
                final String horaFormateada = '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:'
                    '${horaSeleccionada!.minute.toString().padLeft(2, '0')}';

// Debug
                print('==== DEBUG - DATOS DE LA CITA A CREAR ====');
                print('TipoCita: ${tipoSeleccionado == 8 ? 'Consultorio' : 'Domicilio'}');
                print('ID Paciente: ${identificacionPaciente}');
                print('ID Doctor: ${id_doctor}');
                print('Motivo: $motivo');
                print('Fecha: $fechaFormateada');
                print('Hora: $horaFormateada');
                print(mapaDoctoresIDENTI);
                id_doctor = mapaDoctoresIDENTI[doctorSeleccionadoId];
                print(id_doctor);

// Llamada
                crearCita(
                  TipoCita: tipoSeleccionado == 8 ? 'Consultorio' : 'Domicilio',
                  idPaciente: identificacionPaciente!.toString(),
                  fecha: fechaFormateada,
                  hora: horaFormateada,
                  idDoctor: id_doctor!.toString(),
                  motivo: motivo,
                );
              },
              icon: const Icon(Icons.save, size: 16),
              label: Text('Crear Cita', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void crearCita({
    required String TipoCita,
    required String idPaciente,
    required String fecha,
    required String hora,
    required String idDoctor,
    required String motivo,
  }) async {
    try {
      print('🛠 Creando cita con parámetros...');
      print('Tipo Cita: $TipoCita');
      print('Paciente: $idPaciente');
      print('Fecha: $fecha');
      print('Hora: $hora');
      print('Doctor: $idDoctor');

      bool creada = await CitaData().createCita(
        TipoCita,
        idPaciente,
        idDoctor,
        fecha,
        hora,
        motivo
      );

      if (creada) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cita creada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAllCitas(); // Recarga las citas en pantalla
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo crear la cita'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error al crear cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _aplicarFiltroFechas() async {
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona ambas fechas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_fechaInicio!.isAfter(_fechaFin!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de inicio debe ser anterior a la fecha de fin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await CitaData().fetchCitasPorRangoFechas(_fechaInicio!, _fechaFin!);
      setState(() {
        citas = result;
        _filtroActivo = true;
        isLoading = false;
      });
    } catch (e) {
      print('Error al filtrar citas: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al filtrar las citas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _limpiarFiltros() {
    setState(() {
      citas = citasOriginales;
      _filtroActivo = false;
      _fechaInicio = null;
      _fechaFin = null;
    });
  }

  Future<void> _seleccionarFecha(bool esFechaInicio) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3498DB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esFechaInicio) {
          _fechaInicio = fechaSeleccionada;
        } else {
          _fechaFin = fechaSeleccionada;
        }
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return const Color(0xFF3498DB).withOpacity(0.1);
      case 'seguimiento':
        return const Color(0xFF2ECC71).withOpacity(0.1);
      case 'urgencia':
        return const Color(0xFFE74C3C).withOpacity(0.1);
      case 'revision':
        return const Color(0xFFF39C12).withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTipoTextColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return const Color(0xFF3498DB);
      case 'seguimiento':
        return const Color(0xFF2ECC71);
      case 'urgencia':
        return const Color(0xFFE74C3C);
      case 'revision':
        return const Color(0xFFF39C12);
      default:
        return Colors.grey;
    }
  }

  void editarCita(Cita cita) async {
    // Obtener ID del doctor a partir del nombre
    String nombreDoctor = cita.doctor;
    int? auxidDoctor;
    mapaDoctores.forEach((id, nombre) {
      if (nombre == nombreDoctor || nombre == '$nombreDoctor') {
        auxidDoctor = id;
      }
    });

    if (auxidDoctor == null) {
      print('⚠ No se encontró el doctor con nombre: $nombreDoctor');
    }

    String nombrePaciente = cita.paciente;
    print("PACIENTE");
    print(nombrePaciente);
    int? auxidPaciente;
    mapaPacientes.forEach((id, nombre) {
      print(nombre);
      print(nombrePaciente);
      if (nombre == nombrePaciente) {
        auxidPaciente = id;
      }
    });

    if (auxidPaciente == null) {
      print('⚠ No se encontró el paciente con nombre: $nombrePaciente');
    }

    // Variables editables
    int? doctorSeleccionadoId = auxidDoctor;
    int? pacienteSeleccionadoId = auxidPaciente;
    print("-------");
    print(pacienteSeleccionadoId);
    print("---------");
    String motivo = cita.motivo;
    DateTime? fechaSeleccionada = DateTime.tryParse(cita.fecha);
    TimeOfDay? horaSeleccionada = TimeOfDay(
      hour: int.parse(cita.hora.split(':')[0]),
      minute: int.parse(cita.hora.split(':')[1]),
    );
    print(cita.tipo);
    int tipoSeleccionado = cita.tipo == 'Consultorio' ? 8 : 9;
    int estadoSeleccionado = {
      'Pendiente': 10,
      'Cancelada': 11,
      'Realizada': 12,
      'Reprogramada': 13,
    }[cita.estado] ?? 10;

    final TextEditingController motivoController =
    TextEditingController(text: motivo);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.1),
                      const Color(0xFF2980B9).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Color(0xFF3498DB), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Editar Cita',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Información del Paciente', [
                    // Selector de paciente
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Paciente',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: pacienteSeleccionadoId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: pacientes.map((paciente) {
                            return DropdownMenuItem<int>(
                              value: paciente.id_paciente,
                              // Use the paciente field instead of nombre and apellido
                              child: Text(paciente.paciente ?? 'Sin nombre'),
                              // Alternative: If you want to try splitting the name
                              // child: Text(paciente.paciente?.isNotEmpty == true ? paciente.paciente! : 'Sin nombre'),
                            );
                          }).toList(),
                          onChanged: (nuevoId) {
                            setDialogState(() {
                              pacienteSeleccionadoId = nuevoId;
                            });
                          },
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Información Médica', [
                    // Doctor
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Doctor',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: doctorSeleccionadoId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: doctores.map((doctor) {
                            return DropdownMenuItem<int>(
                              value: doctor.id,
                              child: Text('Dr. ${doctor.nombre} ${doctor.apellido}'),
                            );
                          }).toList(),
                          onChanged: (nuevoId) {
                            setDialogState(() {
                              doctorSeleccionadoId = nuevoId;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Motivo
                    TextField(
                      controller: motivoController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Motivo',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (valor) => motivo = valor,
                    ),
                    const SizedBox(height: 10),

                    // Estado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Estado',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: estadoSeleccionado,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('Pendiente')),
                            DropdownMenuItem(value: 11, child: Text('Cancelada')),
                            DropdownMenuItem(value: 12, child: Text('Realizada')),
                            DropdownMenuItem(value: 13, child: Text('Reprogramada')),
                          ],
                          onChanged: (nuevoEstado) {
                            setDialogState(() {
                              estadoSeleccionado = nuevoEstado!;
                            });
                          },
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Detalles de la Cita', [
                    // Fecha
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            fechaSeleccionada = pickedDate;
                          });
                        }
                      },
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        'Fecha',
                        fechaSeleccionada != null
                            ? '${fechaSeleccionada!.year}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.day.toString().padLeft(2, '0')}'
                            : 'Seleccionar',
                      ),
                    ),
                    // Hora
                    GestureDetector(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: horaSeleccionada ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            horaSeleccionada = pickedTime;
                          });
                        }
                      },
                      child: _buildInfoRow(
                        Icons.access_time,
                        'Hora',
                        horaSeleccionada != null
                            ? '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}'
                            : 'Seleccionar',
                      ),
                    ),

                    // Tipo
                    DropdownButtonFormField<int>(
                      value: tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo de cita',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 8, child: Text('Consultorio')),
                        DropdownMenuItem(value: 9, child: Text('Domicilio')),
                      ],
                      onChanged: (valor) {
                        setDialogState(() {
                          tipoSeleccionado = valor!;
                        });
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: Text('Cancelar', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton.icon(
              onPressed: () {

                final String fecha = '${fechaSeleccionada!.year.toString().padLeft(4, '0')}-'
                    '${fechaSeleccionada!.month.toString().padLeft(2, '0')}-'
                    '${fechaSeleccionada!.day.toString().padLeft(2, '0')}';

                final String hora = '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:'
                    '${horaSeleccionada!.minute.toString().padLeft(2, '0')}';

                Navigator.pop(context);
                actualizarCita(
                  id: cita.id,
                  idPaciente: pacienteSeleccionadoId!,
                  motivo: motivo,
                  fecha: fecha,
                  hora: hora,
                  idDoctor: doctorSeleccionadoId!,
                  idTipoCita: tipoSeleccionado,
                  idConsultorio: 1,
                  idEstado: estadoSeleccionado,
                );
              },
              icon: const Icon(Icons.save, size: 16),
              label: Text('Guardar Cambios', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void actualizarCita({
    required int id,
    required int idTipoCita,
    required int idPaciente,
    required int idConsultorio,
    required String fecha,
    required String hora,
    required String motivo,
    required int idEstado,
    required int idDoctor,
  }) async {
    try {
      print('🛠 Actualizando cita con parámetros...');
      print('ID: $id');
      print('Tipo Cita: $idTipoCita');
      print('Paciente: $idPaciente');
      print('Consultorio: $idConsultorio');
      print('Fecha: $fecha');
      print('Hora: $hora');
      print('Motivo: $motivo');
      print('Estado: $idEstado');
      print('Doctor: $idDoctor');

      bool actualizado = await CitaData().updateCita(
        id,
        idTipoCita,
        idPaciente,
        idConsultorio,
        fecha,
        hora,
        motivo,
        idEstado,
        idDoctor,
      );

      if (actualizado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cita actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAllCitas(); // Recarga las citas en pantalla
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo actualizar la cita'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error al actualizar cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  // Método auxiliar para construir secciones de información
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  // Método auxiliar para construir filas de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
// Header con botón "Nueva Cita"
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lista de Citas',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${citas.length} citas ${_filtroActivo ? 'filtradas' : 'registradas'}',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: crearNuevaCita, // <<--- AQUÍ tu función
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Cita'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _filtroActivo ? const Color(0xFF3498DB) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.filter_alt,
                    color: _filtroActivo ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filtros de fecha
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por rango de fechas',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _seleccionarFecha(true),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 10),
                                Text(
                                  _fechaInicio != null
                                      ? _formatearFecha(_fechaInicio!)
                                      : 'Fecha inicio',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: _fechaInicio != null ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _seleccionarFecha(false),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                const SizedBox(width: 10),
                                Text(
                                  _fechaFin != null
                                      ? _formatearFecha(_fechaFin!)
                                      : 'Fecha fin',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: _fechaFin != null ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _aplicarFiltroFechas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Aplicar Filtro',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _limpiarFiltros,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Limpiar',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Lista de citas
            Expanded(
              child: citas.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _filtroActivo ? 'No hay citas en el rango seleccionado' : 'No hay citas registradas',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: citas.length,
                itemBuilder: (context, index) {
                  final cita = citas[index];
                  return Container(
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
                                      color: _getTipoColor(cita.tipo),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      cita.tipo.toUpperCase(),
                                      style: GoogleFonts.roboto(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _getTipoTextColor(cita.tipo),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_services,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dr. ${cita.doctor}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${cita.fecha} - ${cita.hora}',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 28,
                                    child: OutlinedButton.icon(
                                      onPressed: () => editarCita(cita),
                                      icon: const Icon(Icons.edit, size: 14),
                                      label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        foregroundColor: const Color(0xFF3498DB),
                                        side: const BorderSide(color: Color(0xFF3498DB)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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