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
  Future<bool> crearAtencion({
    int? idPaciente,
    int? idHistorial,
    int? idAtencion,
    int tipoAtencion = 1,
    int consultorio = 101,
    String? direccionDomicilio,
    DateTime? fechaAtencion,
    int? idDoctor,
    String? diagnostico,
    String? observaciones,
    String? peso,
    String? altura,
    String total = '0',
    int idTipoPago = 1,
    String? codigoOperacion,
  }) async {
    // Validación mínima opcional
    if (idPaciente == null || idDoctor == null || fechaAtencion == null) {
      print('❌ Faltan datos obligatorios: paciente, doctor o fecha.');
      return false;
    }

    final url = Uri.parse('$baseUrl/atencion');

    final Map<String, dynamic> data = {
      'id_paciente': 11,
      'id_historial': 4,
      'id_atencion': idAtencion,
      'tipo_atencion': tipoAtencion,
      'consultorio': consultorio,
      'direccion_domicilio': direccionDomicilio,
      'fecha_atencion': fechaAtencion.toIso8601String(),
      'id_doctor': idDoctor,
      'diagnostico': diagnostico,
      'observaciones': observaciones,
      'peso': peso,
      'altura': altura,
      'total': total,
      'id_tipo_pago': idTipoPago,
      'codigo_operacion': codigoOperacion,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    print('Código de estado (crear atencion): ${response.statusCode}');
    print('Respuesta: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }
}