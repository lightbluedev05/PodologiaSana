import 'package:flutter/material.dart';
import 'package:podologia_sana/data/doctor_data.dart';
import '../models/doctor_model.dart';

class DoctoresController extends ChangeNotifier {
  final DoctorData _data = DoctorData();
  List<Doctor> _doctores = [];
  List<Doctor> filteredDoctores = [];
  Set<String> selectedIds = {};

  List<Doctor> get doctores => filteredDoctores;

  Future<void> loadDoctores() async {
    try {
      _doctores = await _data.fetchDoctores();
      filteredDoctores = List.from(_doctores);
      notifyListeners();
    } catch (e) {
      print("Error al cargar doctores: $e");
    }
  }

  void filterDoctores(String query) {
    filteredDoctores = _doctores.where((d) {
      final q = query.toLowerCase();
      return d.nombre.toLowerCase().contains(q) ||
          d.apellido.toLowerCase().contains(q) ||
          d.identificacion.contains(query);
    }).toList();
    notifyListeners();
  }

  Future<void> addDoctor(String nombre, String apellido, String telefono,
      String tipoDocumento, String identificacion) async {
    print("Adding doctor: $nombre $apellido");
    final nuevo = Doctor(
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      tipo_documento: tipoDocumento,
      identificacion: identificacion,
    );

    print(nombre + " " + apellido + " " + telefono + " " + tipoDocumento + " " + identificacion);

    try {
      await _data.createDoctor(nuevo);
      print("Doctor added: $nombre $apellido");
      await loadDoctores();
      print("Doctores loaded after adding: ${_doctores.length}");
    } catch (e) {
      print("Error en addDoctor: $e");
      rethrow; // relanza el error para que la vista lo capture y lo muestre
    }
  }

  Future<void> updateDoctor(String identificacion, String nombre, String apellido,
      String telefono, String tipoDocumento, int id) async {
    final actualizado = Doctor(
      id: id,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      tipo_documento: tipoDocumento,
      identificacion: identificacion,
    );
    await _data.updateDoctor(actualizado);
    await loadDoctores();
  }

  Future<void> deleteSelected() async {
    for (var id in selectedIds) {
      await _data.deleteDoctor(id);
    }
    selectedIds.clear();
    await loadDoctores();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }
}
