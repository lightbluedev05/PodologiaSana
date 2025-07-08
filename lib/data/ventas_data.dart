import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ventas_model.dart';

class VentaData {
  final String baseUrl = 'https://podologia-sana.onrender.com';

  Future<Map<String, dynamic>> fetchVentas({int page = 1, int limit = 10}) async {
    final response = await http.get(
        Uri.parse('${baseUrl}/ventas?page=$page&limit=$limit')
    );

    print('Código de estado: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final body = decoded['body'];
      final List data = body['data'];

      return {
        'ventas': data.map((e) => Venta.fromJson(e)).toList(),
        'pagination': body['pagination'],
      };
    } else {
      throw Exception('Error al cargar ventas');
    }
  }

  Future<void> createVenta(Venta venta) async {
    final response = await http.post(
      Uri.parse('$baseUrl/venta'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(venta.toJson()),
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

  Future<List<DetalleVenta>> fetchDetallesVenta(int idVenta) async {
    final response = await http.get(
        Uri.parse('$baseUrl/venta/$idVenta/detalles')
    );
    print(Uri.parse('$baseUrl/venta/$idVenta/detalles'));
    print('Código de estado detalleVenta: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['body'];

      return data.map((e) => DetalleVenta.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Detalles de venta no encontrados');
    } else {
      throw Exception('Error al cargar detalles de venta');
    }
  }
}