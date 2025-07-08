import 'package:flutter/material.dart';
import 'package:podologia_sana/views/login_view.dart';
import 'package:podologia_sana/views/dashboard_admin_view.dart';
import 'package:podologia_sana/views/dashboard_doctor_view.dart';
import 'package:podologia_sana/views/recep_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard_admin = '/dashboard_admin';
  static const String doctores = '/doctores';
  static const String dashboard_doctor = '/dashboard_doctor';
  static const String Estadisticas_Screen = "/EstadisticasScreen";
  static const String recepcionist = "/recepcionist";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case dashboard_admin:
        return MaterialPageRoute(builder: (_) => const DashboardAdminView());
      case dashboard_doctor:
        return MaterialPageRoute(builder: (_) => const DashboardDoctorView(idDoctor: 5));
      case recepcionist:
        return MaterialPageRoute(builder: (_) => const RecepcionistaView());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}