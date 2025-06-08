class Doctor {
  int id;
  String nombre;
  String apellido;
  String telefono;
  String tipo_documento;
  String identificacion;

  Doctor({
    this.id = -1,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.tipo_documento,
    required this.identificacion
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    telefono: json['telefono'],
    tipo_documento: json['tipo_documento'],
    identificacion: json['identificacion'],
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'telefono': telefono,
    'tipo_identificacion': tipo_documento,
    'identificacion': identificacion,
  };
}
