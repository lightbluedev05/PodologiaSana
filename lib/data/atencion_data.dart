import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atencion_model.dart';
import 'citas_data.dart';

class AtencionData {
  final String baseUrl = 'https://podologia-sana.onrender.com';

  Future<List<Atencion>> fetchAllAtencion() async {
    final response = await http.get(Uri.parse('$baseUrl/atencion'));
    print("hola");
    print('Código de estado: ${response.statusCode}');
    print('Cuerpo: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List atencionesJson = decoded['body']['data'];

      final List<Future<Atencion>> atencionFutures = atencionesJson.map((atencionJson) async {
        final atencion = Atencion.fromJson(atencionJson);
        final idCita = atencionJson['id_cita'];
        final String motivo = await CitaData().obtenerMotivoPorIdCita(idCita);

        return atencion.copyWith(motivo: motivo);
      }).toList();

      final atenciones = await Future.wait(atencionFutures);

      // Print debug de todas las atenciones
      for (var a in atenciones) {
        print('Atención => Fecha: ${a.fechaAtencion}, Tipo: ${a.nombreTipoAtencion}, Motivo: ${a.motivo}');
      }

      return atenciones;
    } else {
      throw Exception('Error al obtener todas las atenciones');
    }
  }

  // 2. Obtener atenciones filtradas por ID del doctor
  Future<List<Atencion>> fetchAtencionesPorDoctor(int idDoctor) async {
    final response = await http.get(Uri.parse('$baseUrl/atencion'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List atencionesJson = decoded['body']['data'];

      final filtradas = atencionesJson.where((a) => a['id_doctor'] == idDoctor).toList();

      final List<Future<Atencion>> atencionFutures = filtradas.map((atencionJson) async {
        final atencion = Atencion.fromJson(atencionJson);
        final idCita = atencionJson['id_cita'];
        final String motivo = await CitaData().obtenerMotivoPorIdCita(idCita);

        return atencion.copyWith(motivo: motivo);
      }).toList();

      return await Future.wait(atencionFutures);
    } else {
      throw Exception('Error al obtener atenciones del doctor');
    }
  }

  // 3. Obtener atenciones filtradas por ID del paciente
  Future<List<Atencion>> fetchAtencionesPorPaciente(String NombrePaciente) async {
    final response = await http.get(Uri.parse('$baseUrl/atencion'));
    print("hola");
    print('Código de estado: ${response.statusCode}');
    print('Cuerpo: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List atencionesJson = decoded['body']['data'];

      print("------");
      print(atencionesJson);

      final filtradas = atencionesJson.where((a) => a['nombre_paciente'] == NombrePaciente).toList();

      print("------");
      print(filtradas);

      final List<Future<Atencion>> atencionFutures = filtradas.map((atencionJson) async {
        final atencion = Atencion.fromJson(atencionJson);
        final idCita = atencionJson['id_cita'];
        final String motivo = await CitaData().obtenerMotivoPorIdCita(idCita);

        return atencion.copyWith(motivo: motivo);
      }).toList();

      final atenciones = await Future.wait(atencionFutures);

      print("========== LISTA FINAL ==========");
      for (var a in atenciones) {
        print('Fecha: ${a.fechaAtencion}, Tipo: ${a.nombreTipoAtencion}, Motivo: ${a.motivo}');
      }

      return atenciones;
    } else {
      throw Exception('Error al obtener atenciones del paciente');
    }
  }
}