import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';

class DoctorData {
  final String baseUrl = 'https://podologia-sana.onrender.com';

  Future<List<Doctor>> fetchDoctores() async {
    final response = await http.get(Uri.parse('${baseUrl}/doctores'));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['body']['data'];
      return data.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar doctores');
    }
  }


  Future<void> createDoctor(Doctor doctor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(doctor.toJson()),
    );
    print('Status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      try {
        final decoded = json.decode(response.body);
        final errorBody = decoded['body'];
        final details = errorBody['details'];
        final errorMsg = errorBody['error'];

        if (details is List && details.isNotEmpty) {
          throw Exception(details.join('\n'));
        } else if (errorMsg is String) {
          throw Exception(errorMsg);
        } else {
          throw Exception('Error desconocido del servidor');
        }
      } catch (e) {
        print('Error parseando respuesta: $e');
        throw e;
      }
    }
  }

  Future<void> updateDoctor(Doctor doctor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/doctor/${doctor.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'telefono': doctor.telefono,
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar doctor');
    }
  }

  Future<void> deleteDoctor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/doctor/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar doctor');
    }
  }


  Future<Doctor> fetchDoctorById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/doctor/$id'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['body'];

      return Doctor(
        id: id,
        nombre: data['nombre'],
        apellido: data['apellido'],
        telefono: data['telefono'],
        tipo_documento: data['tipo_documento'],
        identificacion: data['identificacion'],
      );
    } else {
      throw Exception('No se pudo obtener el doctor por ID');
    }
  }
}
