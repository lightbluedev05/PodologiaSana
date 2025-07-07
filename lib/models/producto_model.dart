class Producto {
  int id;
  String nombre;
  String descripcion;
  double precio_venta;
  int stock;
  String categoria;
  String estado;

  Producto({
    this.id = -1,
    required this.nombre,
    required this.descripcion,
    required this.precio_venta,
    required this.stock,
    required this.categoria,
    required this.estado,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'] ?? '',
    precio_venta: json['precio_venta'].toDouble(),
    stock: json['stock'],
    categoria: json['categoria'],
    estado: json['estado'],
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'precio_venta': precio_venta,
    'stock': stock,
    'categoria': categoria,
    'estado': estado,
  };
}
