import 'package:flutter/material.dart';
import 'package:podologia_sana/utils/colors.dart';
import '../controllers/dashboard_admin_controller.dart';
import 'dashboard_admin/inicio_view.dart';
import 'dashboard_admin/doctores_view.dart';
import 'dashboard_admin/pacientes_view.dart';
import 'dashboard_admin/ingresos_view.dart';
import 'dashboard_admin/agenda_view.dart';

class DashboardAdminView extends StatefulWidget {
  const DashboardAdminView({super.key});

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  final DashboardAdminController _controller = DashboardAdminController();

  final List<Widget> _pages = const [
    InicioView(),
    DoctoresView(),
    PacientesView(),
    IngresosView(),
    AgendaView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(title: const Text('Dashboard Admin'))
          : null,
      drawer: isMobile
          ? Drawer(
        child: _controller.buildDrawer(context, onPageSelected),
      )
          : null,
      body: Column(
        children: [
          // Header superior
          Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade100, AppColors.rosaSuave],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.local_hospital, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Podología Sana',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onSelected: (value) => _controller.handleMenuAction(value, context),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'perfil', child: Text('Ver perfil')),
                    const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                  ],
                )
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
          ),
        ],
      ),
    );
  }

  void onPageSelected(int index) {
    setState(() => _controller.changePage(index));
    Navigator.pop(context); // Cierra drawer en móviles
  }
}
