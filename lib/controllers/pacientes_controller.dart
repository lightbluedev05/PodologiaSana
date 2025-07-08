import 'package:flutter/material.dart';
import '../data/paciente_data.dart';
import '../models/paciente_model.dart';

class PacientesController extends ChangeNotifier {
  final PacienteData _data = PacienteData();
  List<Paciente> _pacientes = [];
  List<Paciente> filteredPacientes = [];
  List<int> selectedIds = []; // Cambié a int porque el id_paciente es int

  Future<void> loadPacientes() async {
    print("pacientes_controller: loadPacientes called");
    _pacientes = await _data.fetchPacientes();
    print("pacientes_controller: fetched ${_pacientes.length} pacientes");
    filteredPacientes = List.from(_pacientes);
    notifyListeners();
  }

  void filterPacientes(String query) {
    filteredPacientes = _pacientes.where((p) {
      final nombre = p.nombre ?? '';
      final apellido = p.apellido ?? '';
      return nombre.toLowerCase().contains(query.toLowerCase()) ||
          apellido.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> addPaciente(Paciente paciente) async {
    await _data.createPaciente(paciente);
    await loadPacientes();
  }

  Future<void> updatePaciente(int id, Paciente paciente) async {
    await _data.updatePaciente(id.toString(), paciente);
    await loadPacientes();
  }

  Future<void> deleteSelected() async {
    // Aquí deberías implementar deletePaciente() en PacienteData si no está hecho
    for (int id in selectedIds) {
    }
    selectedIds.clear();
    await loadPacientes();
  }

  List<int> get selected => selectedIds;
  List<Paciente> get pacientes => filteredPacientes;
}
