import 'package:flutter/material.dart';
import '../views/dashboard_doctor/UserInfoWindow.dart';

class DashboardDoctorController {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
  }

  List<NavigationRailDestination> buildDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.calendar_today),
        label: Text('Citas'),
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
        _drawerItem(Icons.calendar_today, 'Citas', 0, onSelect),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserInfoWindow(idDoctor: 5)),
        );
        break;
      case 'logout':
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }
}
