class Cita {
  final int id;
  final String fecha;
  final String hora;
  final String paciente;
  final String motivo;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.paciente,
    required this.motivo,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    String fechaHora = json['fecha_hora'];
    DateTime parsedDate = DateTime.parse(fechaHora);

    return Cita(
      id: json['id_cita'],
      fecha: "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}",
      hora: "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}",
      paciente: json['paciente'],
      motivo: json['motivo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cita': id,
      'fecha': fecha,
      'hora': hora,
      'paciente': paciente,
      'motivo': motivo,
    };
  }
}