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
    required this.alergias,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    // Separar nombre y apellido del campo "paciente"
    String nombreCompleto = json['paciente'] ?? '';
    List<String> partes = nombreCompleto.split(' ');
    String nombre = partes.isNotEmpty ? partes.first : '';
    String apellido = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    // Separar ubicación
    String ubicacion = json['ubicacion'] ?? '';
    List<String> ubicacionPartes = ubicacion.split('-');
    String departamento = ubicacionPartes.length > 0 ? ubicacionPartes[0] : '';
    String provincia = ubicacionPartes.length > 1 ? ubicacionPartes[1] : '';
    String distrito = ubicacionPartes.length > 2 ? ubicacionPartes[2] : '';

    return Paciente(
      numeroHistoria: json['numero_historia'] ?? -1,
      nombre: nombre,
      apellido: apellido,
      tipoIdentificacion: json['identificacion'] ?? '',
      identificacion: json['identificacion'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      distrito: distrito,
      departamento: departamento,
      provincia: provincia,
      direccion: json['direccion'] ?? '',
      tipoPie: json['tipo_pie'] ?? '',
      peso: (json['peso'] ?? 0).toDouble(),
      altura: (json['altura'] ?? 0).toDouble(),
      alergias: json['alergias'] ?? '',
    );
  }

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
    'alergias': alergias,
  };
}