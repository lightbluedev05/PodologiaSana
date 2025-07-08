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

class _PacientesViewState extends State<PacientesView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    Future.microtask(() {
      Provider.of<PacientesController>(context, listen: false).loadPacientes();
      // Iniciar animaciones
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PacientesController>(
      builder: (context, controller, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'search_field',
                          child: Material(
                            color: Colors.transparent,
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton.icon(
                          onPressed: () => _showFormDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text("Nuevo"),
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedList(
                    key: GlobalKey<AnimatedListState>(),
                    initialItemCount: controller.filteredPacientes.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= controller.filteredPacientes.length) {
                        return const SizedBox.shrink();
                      }

                      final paciente = controller.filteredPacientes[index];

                      return SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOut)),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Card(
                                elevation: 2,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: Theme.of(context).textTheme.titleMedium!,
                                      child: Text(paciente.paciente),
                                    ),
                                    subtitle: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      child: Text('ID: ${paciente.identificacion}'),
                                    ),
                                    trailing: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showFormDialog(context, paciente: paciente),
                                        tooltip: 'Editar paciente',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
      builder: (_) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AlertDialog(
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.headlineSmall!,
            child: Text(isEdit ? 'Editar Paciente' : 'Nuevo Paciente'),
          ),
          content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isEdit) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: DropdownButtonFormField<String>(
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
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: identificacionCtrl, decoration: const InputDecoration(labelText: 'Identificación', border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: apellidoCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
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
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: "M", child: Text('Masculino')),
                            DropdownMenuItem(value: "F", child: Text('Femenino')),
                            DropdownMenuItem(value: "O", child: Text('Otro')),
                          ],
                          onChanged: (val) => generoCtrl.text = val ?? '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: departamentoCtrl, decoration: const InputDecoration(labelText: 'Departamento', border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: provinciaCtrl, decoration: const InputDecoration(labelText: 'Provincia', border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: TextField(controller: distritoCtrl, decoration: const InputDecoration(labelText: 'Distrito', border: OutlineInputBorder())),
                      ),
                    ],
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder())),
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: TextField(controller: pesoCtrl, decoration: const InputDecoration(labelText: 'Peso', border: OutlineInputBorder())),
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: TextField(controller: alturaCtrl, decoration: const InputDecoration(labelText: 'Altura', border: OutlineInputBorder())),
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: TextField(controller: alergiasCtrl, decoration: const InputDecoration(labelText: 'Alergias', border: OutlineInputBorder())),
                    ),
                  ],
                ),
              )
          ),
          actions: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar')
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}