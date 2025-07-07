class Atencion {
  int id;
  DateTime fechaAtencion;
  String total;
  String? peso;
  String? altura;
  String? direccionDomicilio;
  String? codigoOperacion;
  String? diagnostico;
  String? observaciones;
  String nombrePaciente;
  String nombreConsultorio;
  String nombreDoctor;
  String nombreTipoAtencion;
  String nombreTipoPago;
  String motivo;

  Atencion({
    required this.id,
    required this.fechaAtencion,
    required this.total,
    this.peso,
    this.altura,
    this.direccionDomicilio,
    this.codigoOperacion,
    this.diagnostico,
    this.observaciones,
    required this.nombrePaciente,
    required this.nombreConsultorio,
    required this.nombreDoctor,
    required this.nombreTipoAtencion,
    required this.nombreTipoPago,
    this.motivo = "defecto",
  });
  Atencion copyWith({String? motivo}) {
    return Atencion(
      id: id,
      fechaAtencion: fechaAtencion,
      total: total,
      peso: peso,
      altura: altura,
      direccionDomicilio: direccionDomicilio,
      codigoOperacion: codigoOperacion,
      diagnostico: diagnostico,
      observaciones: observaciones,
      nombrePaciente: nombrePaciente,
      nombreConsultorio: nombreConsultorio,
      nombreDoctor: nombreDoctor,
      nombreTipoAtencion: nombreTipoAtencion,
      nombreTipoPago: nombreTipoPago,
      motivo: motivo ?? this.motivo,
    );
  }

  factory Atencion.fromJson(Map<String, dynamic> json) {
    return Atencion(
      id: json['id_atencion'],
      fechaAtencion: DateTime.parse(json['fecha_atencion']),
      total: json['total'],
      peso: json['peso'],
      altura: json['altura'],
      direccionDomicilio: json['direccion_domicilio'],
      codigoOperacion: json['codigo_operacion'],
      diagnostico: json['diagnostico'],
      observaciones: json['observaciones'],
      nombrePaciente: json['nombre_paciente'],
      nombreConsultorio: json['nombre_consultorio'],
      nombreDoctor: json['nombre_doctor'],
      nombreTipoAtencion: json['nombre_tipo_atencion'],
      nombreTipoPago: json['nombre_tipo_pago'],
      motivo: json['motivo'] ?? "defecto",
    );
  }

  Atencion.vacio()
      : id = 0,
        fechaAtencion = DateTime.now(),
        total = '',
        peso = null,
        altura = null,
        direccionDomicilio = null,
        codigoOperacion = null,
        diagnostico = null,
        observaciones = null,
        nombrePaciente = '',
        nombreConsultorio = '',
        nombreDoctor = '',
        nombreTipoAtencion = '',
        nombreTipoPago = '',
        motivo = 'defecto';
}