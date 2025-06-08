import 'package:flutter/material.dart';
import 'package:podologia_sana/views/login_view.dart';
import 'package:podologia_sana/views/dashboard_admin_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard_admin = '/dashboard_admin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case dashboard_admin:
        return MaterialPageRoute(builder: (_) => const DashboardAdminView());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
