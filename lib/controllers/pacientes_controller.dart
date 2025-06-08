import 'package:flutter/material.dart';
import '../data/paciente_data.dart';
import '../models/paciente_model.dart';

class PacientesController extends ChangeNotifier {
  final PacienteData _data = PacienteData();
  List<Paciente> _pacientes = [];
  List<Paciente> filteredPacientes = [];
  List<String> selectedIds = [];

  Future<void> loadPacientes() async {
    _pacientes = await _data.fetchPacientes();
    filteredPacientes = List.from(_pacientes);
    notifyListeners();
  }



  void filterPacientes(String query) {
    filteredPacientes = _pacientes
        .where((p) =>
    p.nombre.toLowerCase().contains(query.toLowerCase()) ||
        p.apellido.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> addPaciente(Paciente paciente) async {
    await _data.createPaciente(paciente);
    //await loadPacientes();
  }

  Future<void> updatePaciente(String id, Paciente paciente) async {
    await _data.updatePaciente(id, paciente);
    //await loadPacientes();
  }

  Future<void> deleteSelected() async {
    await _data.deletePacientes(selectedIds);
    selectedIds.clear();
    //await loadPacientes();
  }
}
