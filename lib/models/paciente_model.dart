class Paciente {
  String numeroHistoria;
  String tipoIdentificacion;
  String identificacion;
  String nombre;
  String apellido;
  String fechaNacimiento;
  String telefono;
  String correo;
  String direccion;
  String genero;
  String fechaCreacion;
  String tipoPie;
  String alergias;

  Paciente({
    required this.numeroHistoria,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.telefono,
    required this.correo,
    required this.direccion,
    required this.genero,
    required this.fechaCreacion,
    required this.tipoPie,
    required this.alergias,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
    numeroHistoria: json['numero_historia'],
    tipoIdentificacion: json['tipo_identificacion'],
    identificacion: json['identificacion'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    fechaNacimiento: json['fecha_nacimiento'],
    telefono: json['telefono'],
    correo: json['correo'],
    direccion: json['direccion'],
    genero: json['genero'],
    fechaCreacion: json['fecha_creacion'],
    tipoPie: json['tipo_pie'],
    alergias: json['alergias'],
  );

  Map<String, dynamic> toJson() => {
    'numero_historia': numeroHistoria,
    'tipo_identificacion': tipoIdentificacion,
    'identificacion': identificacion,
    'nombre': nombre,
    'apellido': apellido,
    'fecha_nacimiento': fechaNacimiento,
    'telefono': telefono,
    'correo': correo,
    'direccion': direccion,
    'genero': genero,
    'fecha_creacion': fechaCreacion,
    'tipo_pie': tipoPie,
    'alergias': alergias,
  };
}
