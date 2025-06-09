class TipoIdentificacion {
  final int id;
  final String codigo;
  final String nombre;

  TipoIdentificacion({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  factory TipoIdentificacion.fromJson(Map<String, dynamic> json) {
    return TipoIdentificacion(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() => {
    'codigo': codigo,
    'nombre': nombre,
  };
}