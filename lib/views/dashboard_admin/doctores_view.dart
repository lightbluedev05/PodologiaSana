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
    final identificacionController = TextEditingController(text: doctor?.identificacion);

    final List<String> tiposDocumento = ['DNI', 'Tipo1', 'Tipo2'];
    String selectedTipoDocumento = doctor?.tipo_documento ?? 'DNI';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          bool isFormValid = nombreController.text.trim().isNotEmpty &&
              apellidoController.text.trim().isNotEmpty &&
              telefonoController.text.trim().isNotEmpty &&
              identificacionController.text.trim().isNotEmpty;

          void validateForm() {
            final valid = nombreController.text.trim().isNotEmpty &&
                apellidoController.text.trim().isNotEmpty &&
                telefonoController.text.trim().isNotEmpty &&
                identificacionController.text.trim().isNotEmpty;
            if (valid != isFormValid) {
              setState(() {
                isFormValid = valid;
              });
            }
          }

          // Ejecuta al inicio para validar estado inicial
          WidgetsBinding.instance.addPostFrameCallback((_) {
            validateForm();
          });

          return AlertDialog(
            title: Text(isEditing ? 'Editar Doctor' : 'Nuevo Doctor'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    enabled: !isEditing,
                    onChanged: (_) => validateForm(),
                  ),
                  TextField(
                    controller: apellidoController,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    enabled: !isEditing,
                    onChanged: (_) => validateForm(),
                  ),
                  TextField(
                    controller: telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      final cleaned = value.replaceAll(' ', '');
                      if (value != cleaned) {
                        telefonoController.value = TextEditingValue(
                          text: cleaned,
                          selection: TextSelection.collapsed(offset: cleaned.length),
                        );
                      }
                      validateForm();
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedTipoDocumento,
                    decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                    items: tiposDocumento.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null
                        : (value) {
                      if (value != null) {
                        setState(() {
                          selectedTipoDocumento = value;
                          validateForm();
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: identificacionController,
                    decoration: const InputDecoration(labelText: 'Identificación'),
                    enabled: !isEditing,
                    onChanged: (value) {
                      final cleaned = value.replaceAll(' ', '');
                      if (value != cleaned) {
                        identificacionController.value = TextEditingValue(
                          text: cleaned,
                          selection: TextSelection.collapsed(offset: cleaned.length),
                        );
                      }
                      validateForm();
                    },
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
                onPressed: isFormValid
                    ? () async {
                  if (isEditing) {
                    await controller.updateDoctor(
                      doctor!.identificacion,
                      nombreController.text,
                      apellidoController.text,
                      telefonoController.text,
                      selectedTipoDocumento,
                      doctor.id,
                    );
                  } else {
                    await controller.addDoctor(
                      nombreController.text,
                      apellidoController.text,
                      telefonoController.text,
                      selectedTipoDocumento,
                      identificacionController.text,
                    );
                  }
                  if (mounted) Navigator.of(context).pop();
                }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}