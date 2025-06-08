import 'package:flutter/material.dart';
import '../../controllers/pacientes_controller.dart';
import '../../models/paciente_model.dart';

class PacientesView extends StatefulWidget {
  const PacientesView({super.key});

  @override
  State<PacientesView> createState() => _PacientesViewState();
}

class _PacientesViewState extends State<PacientesView> {
  final PacientesController _controller = PacientesController();
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    //_controller.loadPacientes().then((_) => setState(() {}));
    _controller.loadPacientes();

  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar pacientes...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _controller.filterPacientes(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Nuevo"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _controller.selectedIds.isEmpty
                    ? null
                    : () async {
                  await _controller.deleteSelected();
                  setState(() {});
                },
                icon: const Icon(Icons.delete),
                label: const Text("Eliminar"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _controller.filteredPacientes.length,
            itemBuilder: (context, index) {
              final paciente = _controller.filteredPacientes[index];
              final isSelected =
              _controller.selectedIds.contains(paciente.identificacion);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _controller.toggleSelection(paciente.identificacion);
                      });
                    },
                  ),
                  title: Text('${paciente.nombre} ${paciente.apellido}'),
                  subtitle: Text('ID: ${paciente.identificacion}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showFormDialog(paciente: paciente),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFormDialog({Paciente? paciente}) {
    final isEdit = paciente != null;

    final nombreCtrl = TextEditingController(text: paciente?.nombre);
    final apellidoCtrl = TextEditingController(text: paciente?.apellido);
    final identificacionCtrl = TextEditingController(text: paciente?.identificacion);
    final telefonoCtrl = TextEditingController(text: paciente?.telefono);
    final correoCtrl = TextEditingController(text: paciente?.correo);
    final direccionCtrl = TextEditingController(text: paciente?.direccion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Editar Paciente' : 'Nuevo Paciente'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: apellidoCtrl, decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: identificacionCtrl, decoration: const InputDecoration(labelText: 'Identificación')),
              TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: 'Correo')),
              TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
              // Puedes agregar más campos si deseas
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nuevo = Paciente(
                numeroHistoria: paciente?.numeroHistoria ?? 'N/A',
                tipoIdentificacion: 'DNI',
                identificacion: identificacionCtrl.text,
                nombre: nombreCtrl.text,
                apellido: apellidoCtrl.text,
                fechaNacimiento: '2024-01-01',
                telefono: telefonoCtrl.text,
                correo: correoCtrl.text,
                direccion: direccionCtrl.text,
                genero: 'Otro',
                fechaCreacion: '2024-01-01',
                tipoPie: 'Normal',
                alergias: '',
              );

              if (isEdit) {
                await _controller.updatePaciente(paciente!.identificacion, nuevo);
              } else {
                await _controller.addPaciente(nuevo);
              }

              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
