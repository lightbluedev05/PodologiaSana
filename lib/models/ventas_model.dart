class Venta {
  int id;
  int idPaciente;
  String tipoPago;  // Cambio: ahora es String
  String? codigoOperacion;
  String fechaVenta;
  double total;
  String? nombrePaciente;
  String? apellidoPaciente;
  List<DetalleVenta>? detalles;

  Venta({
    this.id = -1,
    required this.idPaciente,
    required this.tipoPago,  // Cambio: ahora es String requerido
    this.codigoOperacion,
    this.fechaVenta = '',
    this.total = 0.0,
    this.nombrePaciente,
    this.apellidoPaciente,
    this.detalles,
  });

  // Leer a partir de un JSON
  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
    id: json['id'] ?? -1,
    idPaciente: json['id_paciente'],
    tipoPago: json['tipo_pago'],
    codigoOperacion: json['codigo_operacion'],
    fechaVenta: json['fecha_venta'] ?? '',
    total: (json['total'] is String)
        ? double.parse(json['total'])
        : (json['total']?.toDouble() ?? 0.0),
    nombrePaciente: json['nombre_paciente'],
    apellidoPaciente: json['apellido_paciente'],
  );

  // Transformar objeto a JSON para crear venta
  Map<String, dynamic> toJson() => {
    'id_paciente': idPaciente,
    'tipo_pago': tipoPago,  // Cambio: ahora tipo_pago como string
    'codigo_operacion': codigoOperacion,
    'detalles': detalles?.map((detalle) => detalle.toJson()).toList(),
  };
}

class DetalleVenta {
  int id;
  int idVenta;
  int idProducto;  // Cambio: ahora es idProducto
  int cantidad;
  double precioUnitario;
  double subtotal;
  String? nombreProducto;  // Cambio: ahora nombreProducto
  String? descripcionProducto;  // Cambio: ahora descripcionProducto

  DetalleVenta({
    this.id = -1,
    this.idVenta = -1,
    required this.idProducto,  // Cambio: ahora idProducto
    required this.cantidad,
    this.precioUnitario = 0.0,
    this.subtotal = 0.0,
    this.nombreProducto,
    this.descripcionProducto,
  });

  // Leer a partir de un JSON
  factory DetalleVenta.fromJson(Map<String, dynamic> json) => DetalleVenta(
    id: json['id'] ?? -1,
    idVenta: json['id_venta'] ?? -1,
    idProducto: json['id_producto'],  // Cambio: ahora id_producto
    cantidad: json['cantidad'],
    precioUnitario: (json['precio_unitario'] is String)
        ? double.parse(json['precio_unitario'])
        : (json['precio_unitario']?.toDouble() ?? 0.0),
    subtotal: (json['subtotal'] is String)
        ? double.parse(json['subtotal'])
        : (json['subtotal']?.toDouble() ?? 0.0),
    nombreProducto: json['nombre_producto'],
    descripcionProducto: json['descripcion_producto'],
  );

  // Transformar objeto a JSON para crear
  Map<String, dynamic> toJson() => {
    'id_producto': idProducto,  // Cambio: ahora id_producto
    'cantidad': cantidad,
  };
}