import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                      onChanged: controller.filterPacientes,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showFormDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Nuevo"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: controller.selectedIds.isEmpty
                        ? null
                        : () async => controller.deleteSelected(),
                    icon: const Icon(Icons.delete),
                    label: const Text("Eliminar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredPacientes.length,
                itemBuilder: (context, index) {
                  final paciente = controller.filteredPacientes[index];
                  final isSelected = controller.selectedIds.contains(paciente.id_paciente);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => controller.toggleSelection(paciente.id_paciente),
                      ),
                      title: Text(paciente.paciente),
                      subtitle: Text('ID: ${paciente.identificacion}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showFormDialog(context, paciente: paciente),
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

  void _showFormDialog(BuildContext context, {Paciente? paciente}) {
    final isEdit = paciente != null;
    final controller = Provider.of<PacientesController>(context, listen: false);

    final telefonoCtrl = TextEditingController(text: paciente?.telefono ?? '');
    final correoCtrl = TextEditingController(text: paciente?.correo ?? '');
    final pesoCtrl = TextEditingController(text: paciente?.peso.toString() ?? '');
    final alturaCtrl = TextEditingController(text: paciente?.altura.toString() ?? '');
    final alergiasCtrl = TextEditingController(text: paciente?.alergias ?? '');

    final tipoIdentificacionCtrl = TextEditingController();
    final identificacionCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final fechaNacimientoCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();
    final generoCtrl = TextEditingController();
    final departamentoCtrl = TextEditingController();
    final provinciaCtrl = TextEditingController();
    final distritoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Editar Paciente' : 'Nuevo Paciente'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isEdit) ...[
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Identificación',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "dni", child: Text('DNI')),
                      DropdownMenuItem(value: "ce", child: Text('CE')),
                      DropdownMenuItem(value: "pas", child: Text('PAS')),
                    ],
                    onChanged: (val) => tipoIdentificacionCtrl.text = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: identificacionCtrl, decoration: const InputDecoration(labelText: 'Identificación', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: apellidoCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        fechaNacimientoCtrl.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: fechaNacimientoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Nacimiento',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: null,
                    decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: "M", child: Text('Masculino')),
                      DropdownMenuItem(value: "F", child: Text('Femenino')),
                      DropdownMenuItem(value: "O", child: Text('Otro')),
                    ],
                    onChanged: (val) => generoCtrl.text = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: departamentoCtrl, decoration: const InputDecoration(labelText: 'Departamento', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: provinciaCtrl, decoration: const InputDecoration(labelText: 'Provincia', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: distritoCtrl, decoration: const InputDecoration(labelText: 'Distrito', border: OutlineInputBorder())),
                ],
                const SizedBox(height: 12),
                TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: pesoCtrl, decoration: const InputDecoration(labelText: 'Peso', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: alturaCtrl, decoration: const InputDecoration(labelText: 'Altura', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: alergiasCtrl, decoration: const InputDecoration(labelText: 'Alergias', border: OutlineInputBorder())),
              ],
            ),
          )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              // Validación de campos obligatorios
              if (!isEdit) {
                final camposVacios = [];

                if (tipoIdentificacionCtrl.text.isEmpty) camposVacios.add('Tipo de Identificación');
                if (identificacionCtrl.text.isEmpty) camposVacios.add('Identificación');
                if (nombreCtrl.text.isEmpty) camposVacios.add('Nombre');
                if (apellidoCtrl.text.isEmpty) camposVacios.add('Apellido');
                if (fechaNacimientoCtrl.text.isEmpty) camposVacios.add('Fecha de Nacimiento');
                if (telefonoCtrl.text.isEmpty) camposVacios.add('Teléfono');

                if (camposVacios.isNotEmpty) {
                  // Mostrar alerta si hay campos vacíos
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Campos obligatorios'),
                      content: Text(
                        'Debes completar los siguientes campos:\n\n• ${camposVacios.join('\n• ')}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              }

              // Lógica para guardar
              if (isEdit) {
                final actualizado = Paciente(
                  id_paciente: paciente!.id_paciente,
                  numeroHistoria: paciente.numeroHistoria,
                  paciente: paciente.paciente,
                  tipoIdentificacion: paciente.tipoIdentificacion,
                  identificacion: paciente.identificacion,
                  telefono: telefonoCtrl.text.isEmpty ? paciente.telefono : telefonoCtrl.text,
                  correo: correoCtrl.text.isEmpty ? null : correoCtrl.text,
                  peso: (double.tryParse(pesoCtrl.text) ?? 0.0) == 0.0 ? null : double.tryParse(pesoCtrl.text),
                  altura: (double.tryParse(alturaCtrl.text) ?? 0.0) == 0.0 ? null : double.tryParse(alturaCtrl.text),
                  alergias: alergiasCtrl.text.isEmpty ? null : alergiasCtrl.text,
                  ubicacion: paciente.ubicacion,
                  tipoPie: paciente.tipoPie,
                );
                await controller.updatePaciente(paciente.id_paciente, actualizado);
              } else {
                final nuevo = Paciente(
                  id_paciente: 0,
                  numeroHistoria: 0,
                  nombre: nombreCtrl.text,
                  apellido: apellidoCtrl.text,
                  paciente: '${nombreCtrl.text} ${apellidoCtrl.text}',
                  tipoIdentificacion: tipoIdentificacionCtrl.text,
                  identificacion: identificacionCtrl.text,
                  telefono: telefonoCtrl.text,
                  correo: correoCtrl.text.isEmpty ? null : correoCtrl.text,
                  fecha_nacimiento: DateTime.tryParse(fechaNacimientoCtrl.text),
                  direccion: direccionCtrl.text.isEmpty ? null : direccionCtrl.text,
                  genero: generoCtrl.text == 'O' ? null : generoCtrl.text,
                  peso: (double.tryParse(pesoCtrl.text) ?? 0.0) == 0.0 ? null : double.tryParse(pesoCtrl.text),
                  altura: (double.tryParse(alturaCtrl.text) ?? 0.0) == 0.0 ? null : double.tryParse(alturaCtrl.text),
                  alergias: alergiasCtrl.text.isEmpty ? null : alergiasCtrl.text,
                  departamento: departamentoCtrl.text.isEmpty ? null : departamentoCtrl.text,
                  provincia: provinciaCtrl.text.isEmpty ? null : provinciaCtrl.text,
                  distrito: distritoCtrl.text.isEmpty ? null : distritoCtrl.text,
                  ubicacion: '',
                  tipoPie: '',
                );
                await controller.addPaciente(nuevo);
              }

              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
