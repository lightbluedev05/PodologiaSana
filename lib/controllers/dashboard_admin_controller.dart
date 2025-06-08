import 'package:flutter/material.dart';

class DashboardAdminController {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
  }

  List<NavigationRailDestination> buildDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text('Inicio'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.medical_services),
        label: Text('Doctores'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.people),
        label: Text('Pacientes'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.attach_money),
        label: Text('Ingresos'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.calendar_today),
        label: Text('Agenda'),
      ),
    ];
  }

  Widget buildDrawer(BuildContext context, Function(int) onSelect) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        _drawerItem(Icons.home, 'Inicio', 0, onSelect),
        _drawerItem(Icons.medical_services, 'Doctores', 1, onSelect),
        _drawerItem(Icons.people, 'Pacientes', 2, onSelect),
        _drawerItem(Icons.attach_money, 'Ingresos', 3, onSelect),
        _drawerItem(Icons.calendar_today, 'Agenda', 4, onSelect),
      ],
    );
  }

  Widget _drawerItem(IconData icon, String label, int index, Function(int) onSelect) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: currentIndex == index,
      onTap: () => onSelect(index),
    );
  }

  void handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'perfil':
      // Redirigir a la vista de perfil
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ver perfil (en desarrollo)")));
        break;
      case 'logout':
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }
}
