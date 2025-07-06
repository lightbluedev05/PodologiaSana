class Cita {
  final int id;
  final String fecha;
  final String hora;
  final String paciente;
  final String motivo;
  final String tipo;
  final String doctor;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.paciente,
    required this.motivo,
    required this.tipo,
    required this.doctor
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    String fechaHora = json['fecha_hora'];
    DateTime parsedDate = DateTime.parse(fechaHora);

    String tipoEvento = 'otro';

    tipoEvento = json['tipo_cita'].toString().toLowerCase();

    String nombreDoctor = "none";
    nombreDoctor = json['doctor'].toString();

    return Cita(
      id: json['id_cita'],
      fecha: "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}",
      hora: "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}",
      paciente: json['paciente'],
      motivo: json['motivo'],
      tipo: tipoEvento,
      doctor: nombreDoctor,
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