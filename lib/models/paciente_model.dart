class Paciente {
  int numeroHistoria;
  String nombre;
  String apellido;
  String tipoIdentificacion;
  String identificacion;
  String telefono;
  String correo;
  String distrito;
  String departamento;
  String provincia;
  String direccion;
  String tipoPie;
  double peso;
  double altura;
  String alergias;

  Paciente({
    this.numeroHistoria = -1,
    required this.nombre,
    required this.apellido,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.telefono,
    required this.correo,
    required this.distrito,
    required this.departamento,
    required this.provincia,
    required this.direccion,
    required this.tipoPie,
    required this.peso,
    required this.altura,
    required this.alergias
  });

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
    numeroHistoria: json['numero_historia'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    tipoIdentificacion: json['tipo_identificacion'],
    identificacion: json['identificacion'],
    telefono: json['telefono'],
    correo: json['correo'],
    distrito: json['distrito'],
    departamento: json['departamento'],
    provincia: json['provincia'],
    direccion: json['direccion'],
    tipoPie: json['tipo_pie'],
    peso: json['peso'],
    altura: json['altura'],
    alergias: json['alergias']
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'tipo_identificacion': tipoIdentificacion,
    'identificacion': identificacion,
    'telefono': telefono,
    'correo': correo,
    'distrito': distrito,
    'departamento': departamento,
    'provincia': provincia,
    'direccion': direccion,
    'tipo_pie': tipoPie,
    'peso': peso,
    'altura': altura,
    'alergias': alergias
  };
}
