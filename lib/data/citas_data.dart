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

  // 6. Obtener citas por fecha exacta (sin importar estado ni doctor)
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
}