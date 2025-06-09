import '../models/identificacion_tipo.dart';
import '../data/identificacion_tipo_data.dart';

class TipoIdentificacionController {
  final TipoIdentificacionData _data = TipoIdentificacionData();

  List<TipoIdentificacion> _tipos = [];

  Future<void> loadTipos() async {
    _tipos = await _data.fetchTipos();
  }

  List<TipoIdentificacion> get tipos => _tipos;

  Future<List<String>> obtenerNombresTipos() async {
    if (_tipos.isEmpty) await loadTipos();
    return _tipos.map((e) => e.nombre).toList();
  }
}