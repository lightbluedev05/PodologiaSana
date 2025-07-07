import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/doctores_controller.dart';
import '../../controllers/identificacion_tipo_controller.dart';
import '../../models/doctor_model.dart';

class DoctoresView extends StatefulWidget {
  const DoctoresView({super.key});

  @override
  State<DoctoresView> createState() => _DoctoresViewState();
}

class _DoctoresViewState extends State<DoctoresView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TipoIdentificacionController _identificacionController = TipoIdentificacionController();

  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;

  List<String> TiposID = [];
  String? selectedTipoDocumento;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.microtask(() async {
      Provider.of<DoctoresController>(context, listen: false).loadDoctores();
      TiposID = await _identificacionController.obtenerNombresTipos();

      if (TiposID.isNotEmpty) {
        selectedTipoDocumento = TiposID[0];
      }

      setState(() {
        _isLoading = false;
      });

      // Iniciar animaciones
      _listAnimationController.forward();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctoresController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            // Header con search y botón
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar doctores...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: controller.filterDoctores,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScaleTransition(
                    scale: _fabAnimationController,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _showCreateDoctorDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Nuevo',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de doctores
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : controller.doctores.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay doctores registrados',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega el primer doctor usando el botón "Nuevo"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : AnimatedBuilder(
                animation: _listAnimationController,
                builder: (context, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.doctores.length,
                    itemBuilder: (context, index) {
                      final doctor = controller.doctores[index];
                      final animationDelay = index * 0.1;

                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _listAnimationController,
                            curve: Interval(
                              animationDelay.clamp(0.0, 1.0),
                              (animationDelay + 0.3).clamp(0.0, 1.0),
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _listAnimationController,
                              curve: Interval(
                                animationDelay.clamp(0.0, 1.0),
                                (animationDelay + 0.3).clamp(0.0, 1.0),
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                          child: _buildDoctorCard(doctor, index),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorCard(Doctor doctor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Animación de tap suave
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar del doctor
                      Hero(
                        tag: 'doctor_avatar_${doctor.id}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Información del doctor
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${doctor.nombre} ${doctor.apellido}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.telefono,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.badge,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${doctor.tipo_documento}: ${doctor.identificacion}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Botones de acción
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.blue,
                            onPressed: () => _showDoctorFormDialog(doctor: doctor),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: () => _showDeleteConfirmation(doctor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Doctor doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar al doctor ${doctor.nombre} ${doctor.apellido}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
            onPressed: () async {
              try {
                final controller = Provider.of<DoctoresController>(context, listen: false);
                await controller.deleteById(doctor.id);
                if (mounted) Navigator.of(context).pop();
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Error'),
                      ],
                    ),
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
          ),
        ],
      ),
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

    String? dialogSelectedTipoDocumento =
    isEditing ? doctor!.tipo_documento : (TiposID.isNotEmpty ? TiposID[0] : null);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          bool isFormValid = nombreController.text.trim().isNotEmpty &&
              apellidoController.text.trim().isNotEmpty &&
              telefonoController.text.trim().isNotEmpty &&
              identificacionController.text.trim().isNotEmpty &&
              dialogSelectedTipoDocumento != null;

          void validateForm() {
            final valid = nombreController.text.trim().isNotEmpty &&
                apellidoController.text.trim().isNotEmpty &&
                telefonoController.text.trim().isNotEmpty &&
                identificacionController.text.trim().isNotEmpty &&
                dialogSelectedTipoDocumento != null;
            if (valid != isFormValid) {
              setState(() {
                isFormValid = valid;
              });
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            validateForm();
          });

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit : Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(isEditing ? 'Editar Doctor' : 'Nuevo Doctor'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormField(
                    controller: nombreController,
                    label: 'Nombre',
                    icon: Icons.person,
                    enabled: !isEditing,
                    onChanged: (_) => validateForm(),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: apellidoController,
                    label: 'Apellido',
                    icon: Icons.person_outline,
                    enabled: !isEditing,
                    onChanged: (_) => validateForm(),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone,
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
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: dialogSelectedTipoDocumento,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Documento',
                        prefixIcon: Icon(Icons.badge, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: TiposID.map((tipo) {
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
                            dialogSelectedTipoDocumento = value;
                            validateForm();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: identificacionController,
                    label: 'Identificación',
                    icon: Icons.credit_card,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid ? Theme.of(context).primaryColor : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Guardar'),
                onPressed: isFormValid
                    ? () async {
                  try {
                    if (isEditing) {
                      await controller.updateDoctor(
                        doctor!.identificacion,
                        nombreController.text,
                        apellidoController.text,
                        telefonoController.text,
                        dialogSelectedTipoDocumento!,
                        doctor.id,
                      );
                    } else {
                      await controller.addDoctor(
                        nombreController.text,
                        apellidoController.text,
                        telefonoController.text,
                        dialogSelectedTipoDocumento!,
                        identificacionController.text,
                      );
                    }
                    if (mounted) Navigator.of(context).pop();
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Error'),
                          ],
                        ),
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
                }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: enabled ? Colors.white : Colors.grey[50],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}