import 'package:flutter/material.dart';
import '../../controllers/pacientes_controller.dart';
import '../../models/paciente_model.dart';
import 'package:provider/provider.dart';

class PacientesView extends StatefulWidget {
  const PacientesView({super.key});

  @override
  State<PacientesView> createState() => _PacientesViewState();
}

class _PacientesViewState extends State<PacientesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PacientesController>(context, listen: false).loadPacientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PacientesController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 12),
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
                      onChanged: controller.filterPacientes,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showFormDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Nuevo"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredPacientes.length,
                itemBuilder: (context, index) {
                  final paciente = controller.filteredPacientes[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text('${paciente.nombre} ${paciente.apellido}'),
                      subtitle: Text('ID: ${paciente.identificacion}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showFormDialog(context, paciente: paciente),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _showDeleteConfirmDialog(context, paciente),
                          ),
                        ],
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

  void _showDeleteConfirmDialog(BuildContext context, Paciente paciente) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar al paciente "${paciente.nombre} ${paciente.apellido}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final controller = Provider.of<PacientesController>(context, listen: false);
                await controller.deletePaciente(paciente.identificacion);
                if (mounted) Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    actions: [
                      TextButton(
                        child: const Text('Cerrar'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, {Paciente? paciente}) {
    final isEdit = paciente != null;
    final controller = Provider.of<PacientesController>(context, listen: false);

    final nombreCtrl = TextEditingController(text: paciente?.nombre);
    final apellidoCtrl = TextEditingController(text: paciente?.apellido);
    final identificacionCtrl = TextEditingController(
        text: paciente?.identificacion);
    final tipoIdentificacionCtrl = TextEditingController(
        text: paciente?.tipoIdentificacion ?? 'DNI');
    final telefonoCtrl = TextEditingController(text: paciente?.telefono);
    final correoCtrl = TextEditingController(text: paciente?.correo);
    final direccionCtrl = TextEditingController(text: paciente?.direccion);
    final distritoCtrl = TextEditingController(text: paciente?.distrito);
    final provinciaCtrl = TextEditingController(text: paciente?.provincia);
    final departamentoCtrl = TextEditingController(
        text: paciente?.departamento);
    final tipoPieCtrl = TextEditingController(text: paciente?.tipoPie);
    final pesoCtrl = TextEditingController(text: paciente?.peso.toString());
    final alturaCtrl = TextEditingController(text: paciente?.altura.toString());
    final alergiasCtrl = TextEditingController(text: paciente?.alergias);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Editar Paciente' : 'Nuevo Paciente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: apellidoCtrl,
                  decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: tipoIdentificacionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Tipo Identificación')),
              TextField(controller: identificacionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Identificación')),
              TextField(controller: telefonoCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono')),
              TextField(controller: correoCtrl,
                  decoration: const InputDecoration(labelText: 'Correo')),
              TextField(controller: direccionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Dirección')),
              TextField(controller: distritoCtrl,
                  decoration: const InputDecoration(labelText: 'Distrito')),
              TextField(controller: provinciaCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Provincia')),
              TextField(controller: departamentoCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Departamento')),
              TextField(controller: tipoPieCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Tipo de Pie')),
              TextField(
                controller: pesoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
              ),
              TextField(
                controller: alturaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
              ),
              TextField(controller: alergiasCtrl,
                  decoration: const InputDecoration(labelText: 'Alergias')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final nuevo = Paciente(
                  numeroHistoria: paciente?.numeroHistoria ?? 0,
                  nombre: nombreCtrl.text,
                  apellido: apellidoCtrl.text,
                  tipoIdentificacion: tipoIdentificacionCtrl.text,
                  identificacion: identificacionCtrl.text,
                  telefono: telefonoCtrl.text,
                  correo: correoCtrl.text,
                  direccion: direccionCtrl.text,
                  distrito: distritoCtrl.text,
                  provincia: provinciaCtrl.text,
                  departamento: departamentoCtrl.text,
                  tipoPie: tipoPieCtrl.text,
                  peso: double.tryParse(pesoCtrl.text) ?? 0.0,
                  altura: double.tryParse(alturaCtrl.text) ?? 0.0,
                  alergias: alergiasCtrl.text,
                );

                if (isEdit) {
                  await controller.updatePaciente(
                      paciente!.identificacion, nuevo);
                } else {
                  await controller.addPaciente(nuevo);
                }

                if (mounted) Navigator.of(context).pop();
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    actions: [
                      TextButton(
                        child: const Text('Cerrar'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}