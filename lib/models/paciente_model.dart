
import 'package:intl/intl.dart';

class Paciente {
  int id_paciente;
  int numeroHistoria;

  String? nombre;
  String? apellido;
  String paciente;

  int? id_tipoIdentificacion;
  String tipoIdentificacion;
  String identificacion;
  String telefono;
  String? correo;
  DateTime? fecha_nacimiento;

  String? id_ubigeo;
  String? direccion;
  String ubicacion;
  String? departamento;
  String? provincia;
  String? distrito;

  String? genero;

  int? id_tipoPie;
  String tipoPie;

  double? peso;
  double? altura;
  String? alergias;

  int? es_paciente_medico;

  Paciente({
    required this.id_paciente,
    required this.numeroHistoria,

    this.nombre,
    this.apellido,
    required this.paciente,

    required this.tipoIdentificacion,
    required this.identificacion,
    required this.telefono,
    required this.correo,
    this.fecha_nacimiento,

    this.id_ubigeo,
    this.direccion,
    required this.ubicacion,
    this.departamento,
    this.provincia,
    this.distrito,

    this.genero,

    this.id_tipoPie,
    required this.tipoPie,

    required this.peso,
    required this.altura,
    required this.alergias,

    this.es_paciente_medico
  });

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
    id_paciente: json['id_paciente'] ?? 0,
    numeroHistoria: json['numero_historia'] ?? 0,
    paciente: json['paciente'] ?? '',
    tipoIdentificacion: json['tipo_identificacion'] ?? '',
    identificacion: json['identificacion'] ?? '',
    telefono: json['telefono'] ?? '',
    correo: json['correo'] ?? '',
    ubicacion: json['ubicacion'] ?? '',
    tipoPie: json['tipo_pie'] ?? '',
    peso: (json['peso'] ?? 0).toDouble(),
    altura: (json['altura'] ?? 0).toDouble(),
    alergias: json['alergias'] ?? '',
  );


  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = {
      'tipo_identificacion': tipoIdentificacion,
      'identificacion': identificacion,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fecha_nacimiento != null
          ? DateFormat('yyyy-MM-dd').format(fecha_nacimiento!)
          : null,
      'telefono': telefono,
    };

    // Solo agregar si NO son null
    if (correo != null) data['correo'] = correo;
    if (genero != null) data['genero'] = genero;
    if (direccion != null) data['direccion'] = direccion;
    if (peso != null) data['peso'] = peso;
    if (altura != null) data['altura'] = altura;
    if (alergias != null) data['alergias'] = alergias;

    // Agregar ubigeo solo si los tres existen
    if (departamento != null && provincia != null && distrito != null) {
      data['departamento'] = departamento;
      data['provincia'] = provincia;
      data['distrito'] = distrito;
    }

    return data;
  }


  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {
      'id': id_paciente,
      'telefono': telefono == null ? '' : telefono,
      'correo': correo == null ? '' : correo,
      'peso': peso == null ? 0.0 : peso,
      'alergias': alergias == null ? '' : alergias,
    };

    return data;
  }

}
