import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class UsuarioData {
  final String _url = 'https://podologia-sana.onrender.com/login';

  Future<Usuario> loginUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(usuario.toJson()),
    );

    print('Status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['body']['usuario'];

      print(data);

      return Usuario.fromJson(data);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }
}
