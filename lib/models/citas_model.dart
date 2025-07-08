class Cita {
  final int id;
  final String fecha;
  final String hora;
  final String paciente;
  final String motivo;
  final String tipo;
  final String doctor;
  final String estado;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.paciente,
    required this.motivo,
    required this.tipo,
    required this.doctor,
    required this.estado
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    String fechaHora = json['fecha_hora'] ?? '';
    DateTime parsedDate = DateTime.tryParse(fechaHora) ?? DateTime.now();

    return Cita(
      id: json['id_cita'] ?? 0,
      fecha: "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}",
      hora: "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}",
      paciente: json['paciente']?.toString() ?? 'Sin nombre',
      motivo: json['motivo']?.toString() ?? 'Sin motivo',
      tipo: json['tipo_cita']?.toString() ?? 'Desconocido',
      doctor: json['doctor']?.toString() ?? 'Desconocido',
      estado: json['estado']?.toString() ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cita': id,
      'fecha': fecha,
      'hora': hora,
      'paciente': paciente,
      'motivo': motivo,
      'tipo': tipo,
      'doctor': doctor,
    };
  }

  @override
  String toString() {
    return 'Cita(id: $id, fecha: $fecha, hora: $hora, paciente: $paciente, motivo: $motivo, tipo: $tipo)';
  }
}