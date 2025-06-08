import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/doctores_controller.dart';
import '../../models/doctor_model.dart';

class DoctoresView extends StatefulWidget {
  const DoctoresView({super.key});

  @override
  State<DoctoresView> createState() => _DoctoresViewState();
}

class _DoctoresViewState extends State<DoctoresView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DoctoresController>(context, listen: false).loadDoctores());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctoresController>(
      builder: (context, controller, child) {
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
                        hintText: 'Buscar doctores...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: controller.filterDoctores,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showCreateDoctorDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: controller.selectedIds.isEmpty
                        ? null
                        : () => controller.deleteSelected(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.doctores.length,
                itemBuilder: (context, index) {
                  final doctor = controller.doctores[index];
                  final isSelected =
                  controller.selectedIds.contains(doctor.identificacion);

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) =>
                            controller.toggleSelection(doctor.identificacion),
                      ),
                      title: Text('${doctor.nombre} ${doctor.apellido}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tel: ${doctor.telefono}'),
                          Text('${doctor.tipo_documento}: ${doctor.identificacion}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showDoctorFormDialog(doctor: doctor),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDoctorDialog() {
    _showDoctorFormDialog();
  }

  void _showDoctorFormDialog({Doctor? doctor}) {
    final isEditing = doctor != null;
    final controller = Provider.of<DoctoresController>(context, listen: false);
    final nombreController = TextEditingController(text: doctor?.nombre);
    final apellidoController = TextEditingController(text: doctor?.apellido);
    final telefonoController = TextEditingController(text: doctor?.telefono);
    final tipoDocumentoController =
    TextEditingController(text: doctor?.tipo_documento);
    final identificacionController =
    TextEditingController(text: doctor?.identificacion);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Editar Doctor' : 'Nuevo Doctor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                enabled: !isEditing
              ),
              TextField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                enabled: !isEditing
              ),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                enabled: true
              ),
              TextField(
                controller: tipoDocumentoController,
                decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                enabled: !isEditing
              ),
              TextField(
                controller: identificacionController,
                decoration: const InputDecoration(labelText: 'Identificación'),
                enabled: !isEditing,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Guardar'),
            onPressed: () async {
              if (isEditing) {
                await controller.updateDoctor(
                  doctor!.identificacion,
                  nombreController.text,
                  apellidoController.text,
                  telefonoController.text,
                  tipoDocumentoController.text,
                  doctor.id
                );
              } else {
                await controller.addDoctor(
                  nombreController.text,
                  apellidoController.text,
                  telefonoController.text,
                  tipoDocumentoController.text,
                  identificacionController.text,
                );
              }
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
