import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/identificacion_tipo.dart';

class TipoIdentificacionData {
  static const String _baseUrl = 'https://podologia-sana.onrender.com/tipo-identificacion';

  Future<List<TipoIdentificacion>> fetchTipos() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> lista = jsonBody['body'];
      return lista.map((e) => TipoIdentificacion.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar tipos de identificación');
    }
  }
}