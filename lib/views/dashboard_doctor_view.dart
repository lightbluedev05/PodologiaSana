import 'package:flutter/material.dart';
import 'package:podologia_sana/controllers/dashboard_doctor_controller.dart';
import 'package:podologia_sana/data/doctor_data.dart';
import 'package:podologia_sana/models/doctor_model.dart';
import 'dashboard_doctor/citas_view.dart';
import '../../utils/colors.dart';
import 'dashboard_doctor/pagos_view.dart';

final idDoctor = 5; // ID del doctor para pruebas, cambiar según sea necesario

class DashboardDoctorView extends StatefulWidget {
  const DashboardDoctorView({super.key});

  @override
  State<DashboardDoctorView> createState() => _DashboardDoctorViewState();
}

class _DashboardDoctorViewState extends State<DashboardDoctorView> {
  final DashboardDoctorController _controller = DashboardDoctorController();

  Doctor? doctor;
  bool isLoading = true;

  final List<Widget> _pages = const [
    CitasView("Luis Quispe"),
    PagosView(), // Nuevo
  ];


  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    try {
      Doctor d = await DoctorData().fetchDoctorById(5);
      setState(() {
        doctor = d;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar doctor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text('Dashboard Doctor')) : null,
      drawer: isMobile ? Drawer(child: _controller.buildDrawer(context, onPageSelected)) : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Header superior
          Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.rosaSuave,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dr. ${doctor!.nombre} ${doctor!.apellido}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onSelected: (value) => _controller.handleMenuAction(value, context),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'perfil', child: Text('Ver perfil')),
                    PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (!isMobile)
                  NavigationRail(
                    selectedIndex: _controller.currentIndex,
                    onDestinationSelected: (index) => setState(() => _controller.changePage(index)),
                    labelType: NavigationRailLabelType.all,
                    destinations: _controller.buildDestinations(),
                  ),
                if (!isMobile) const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: _pages[_controller.currentIndex],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onPageSelected(int index) {
    setState(() => _controller.changePage(index));
    Navigator.pop(context);
  }
}