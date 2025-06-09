class CategoriaProducto {
  int id;
  String codigo;
  String nombre;

  CategoriaProducto({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  factory CategoriaProducto.fromJson(Map<String, dynamic> json) {
    return CategoriaProducto(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
    };
  }
}