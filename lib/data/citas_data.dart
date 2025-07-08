import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/citas_model.dart';

class CitaData {
  final String baseUrl = 'https://podologia-sana.onrender.com';

  // 1. Obtener todas las citas
  Future<List<Cita>> fetchAllCitas() async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];

      citas.sort((a, b) {
        final DateTime fechaA = DateTime.parse(a['fecha_hora']);
        final DateTime fechaB = DateTime.parse(b['fecha_hora']);
        return fechaA.compareTo(fechaB); // más antigua primero
      });

      return citas.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener todas las citas');
    }
  }

  // 2. Obtener citas con estado "Realizada" y filtradas por doctor
  Future<List<Cita>> fetchCitasRealizadas(String nombreDoctor) async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];

      final List realizadas = citas.where((cita) =>
      cita['estado'].toString().toLowerCase() == 'realizada' &&
          cita['doctor'] == nombreDoctor
      ).toList();

      realizadas.sort((a, b) {
        final DateTime fechaA = DateTime.parse(a['fecha_hora']);
        final DateTime fechaB = DateTime.parse(b['fecha_hora']);
        return fechaA.compareTo(fechaB); // más antigua primero
      });

      return realizadas.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener citas realizadas');
    }
  }

  // 3. Obtener solo las citas del día de hoy filtradas por doctor
  Future<List<Cita>> fetchCitasHoy(String nombreDoctor) async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];
      final hoy = DateTime.now();

      final List citasHoy = citas.where((cita) {
        final fechaCita = DateTime.parse(cita['fecha_hora']);
        return fechaCita.year == hoy.year &&
            fechaCita.month == hoy.month &&
            fechaCita.day == hoy.day &&
            cita['doctor'] == nombreDoctor &&
            cita['estado'].toString().toLowerCase() == 'pendiente';
      }).toList();

      citasHoy.sort((a, b) {
        final DateTime fechaA = DateTime.parse(a['fecha_hora']);
        final DateTime fechaB = DateTime.parse(b['fecha_hora']);
        return fechaA.compareTo(fechaB); // más antigua primero
      });

      return citasHoy.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener citas de hoy');
    }
  }

  // 4. Contar cantidad de citas de hoy para un doctor
  Future<int> contarCitasHoy(String nombreDoctor) async {
    final citasHoy = await fetchCitasHoy(nombreDoctor);
    return citasHoy.length;
  }

  // 5. Citas por doctor con estado pendiente
  Future<List<Cita>> fetchCitasPorDoctor(String nombreDoctor) async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];

      final List filtradas = citas.where((cita) =>
      cita['doctor'] == nombreDoctor &&
          cita['estado'].toString().toLowerCase() == 'pendiente'
      ).toList();

      filtradas.sort((a, b) {
        final DateTime fechaA = DateTime.parse(a['fecha_hora']);
        final DateTime fechaB = DateTime.parse(b['fecha_hora']);
        return fechaA.compareTo(fechaB); // más antigua primero
      });

      return filtradas.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener citas del doctor');
    }
  }

  Future<List<Cita>> fetchCitasPorFecha(DateTime fecha) async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];

      final List citasFiltradas = citas.where((cita) {
        final fechaCita = DateTime.parse(cita['fecha_hora']);
        return fechaCita.year == fecha.year &&
            fechaCita.month == fecha.month &&
            fechaCita.day == fecha.day;
      }).toList();

      citasFiltradas.sort((a, b) {
        final DateTime fechaA = DateTime.parse(a['fecha_hora']);
        final DateTime fechaB = DateTime.parse(b['fecha_hora']);
        return fechaA.compareTo(fechaB); // más antigua primero
      });

      return citasFiltradas.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener citas por fecha');
    }
  }

  // NUEVO: Obtener citas por rango de fechas
  Future<List<Cita>> fetchCitasPorRangoFechas(DateTime fechaInicio, DateTime fechaFin) async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];

      // Normalizar las fechas para comparación (solo fecha, sin hora)
      final DateTime inicioNormalizado = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
      final DateTime finNormalizado = DateTime(fechaFin.year, fechaFin.month, fechaFin.day, 23, 59, 59);

      final List citasFiltradas = citas.where((cita) {
        final fechaCita = DateTime.parse(cita['fecha_hora']);
        final DateTime citaNormalizada = DateTime(fechaCita.year, fechaCita.month, fechaCita.day);

        return (citaNormalizada.isAtSameMomentAs(inicioNormalizado) ||
            citaNormalizada.isAfter(inicioNormalizado)) &&
            (citaNormalizada.isAtSameMomentAs(DateTime(finNormalizado.year, finNormalizado.month, finNormalizado.day)) ||
                citaNormalizada.isBefore(DateTime(finNormalizado.year, finNormalizado.month, finNormalizado.day).add(Duration(days: 1))));
      }).toList();

      citasFiltradas.sort((a, b) {
        final DateTime fechaA = DateTime.parse(a['fecha_hora']);
        final DateTime fechaB = DateTime.parse(b['fecha_hora']);
        return fechaA.compareTo(fechaB); // más antigua primero
      });

      return citasFiltradas.map((e) => Cita.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener citas por rango de fechas');
    }
  }

  Future<String> obtenerMotivoPorIdCita(int idCita) async {
    final response = await http.get(Uri.parse('$baseUrl/citas'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List citas = decoded['body']['data'];
      final cita = citas.firstWhere(
            (c) => c['id_cita'] == idCita,
        orElse: () => null,
      );

      if (cita != null) {
        return cita['motivo'] ?? 'Sin motivo';
      } else {
        throw Exception('No se encontró la cita con ID $idCita');
      }
    } else {
      throw Exception('Error al obtener las citas');
    }
  }

  // MÉTODOS CRUD PARA ADMIN

  // 7. Crear nueva cita
  Future<bool> createCita(String tipo_cita, String id_paciente, String id_doctor ,DateTime fecha, DateTime hora, String motivo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/citas'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tipo_cita': tipo_cita,
        'consultrio': "101",
        'iden_paciente': id_paciente,
        'iden_doctor': id_doctor,
        'fecha': fecha.toIso8601String(),
        'hora': hora.toIso8601String(),
        'motivo': motivo,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 8. Actualizar cita existente
  Future<bool> updateCita(int id, int idTipoCita, int idPaciente, int idConsultorio, String fecha, String hora, String motivo, int tipo, int idDoctor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/citas/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id_tipo_cita': idTipoCita,
        'id_paciente': idPaciente,
        'id_consultorio': idConsultorio,
        'fecha': fecha,
        'hora': hora,
        'motivo': motivo,
        'id_tipo_estado': tipo,
        'id_doctor': idDoctor,
      }),
    );

    return response.statusCode == 200;
  }

  // 9. Eliminar cita
  Future<bool> deleteCita(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/citas/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  // 10. Obtener una cita específica por ID
  Future<Cita?> fetchCitaById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/citas/$id'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final citaData = decoded['body']['data'];
      return Cita.fromJson(citaData);
    } else {
      return null;
    }
  }
}