import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paciente_model.dart';

class PacienteData {
  final String baseUrl = 'https://podologia-sana.onrender.com';

  Future<List<Paciente>> fetchPacientes() async {
    print("paciente_data: fetchPacientes called");
    final response = await http.get(Uri.parse('$baseUrl/pacientes'));
    print("responde ok");
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['body']['data'];
      return data.map((e) => Paciente.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar pacientes');
    }
  }

  Future<void> createPaciente(Paciente paciente) async {
    print("paciente_data: createPaciente called with ${paciente.toCreateJson()}");
    await http.post(
      Uri.parse('$baseUrl/paciente'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(paciente.toCreateJson()),
    );
  }

  Future<void> updatePaciente(String id, Paciente paciente) async {
    print("paciente_data: updatePaciente called with id $id and ${paciente.toUpdateJson()}");
    print(jsonEncode(paciente.toUpdateJson()));
    await http.put(
      Uri.parse('$baseUrl/paciente/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(paciente.toUpdateJson()),
    );
  }
}
