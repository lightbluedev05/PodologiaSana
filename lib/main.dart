import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podologia_sana/app_routes.dart';
import 'package:podologia_sana/controllers/doctores_controller.dart';
import 'package:podologia_sana/views/dashboard_admin/doctores_view.dart';
import 'package:podologia_sana/controllers/pacientes_controller.dart';
import 'package:podologia_sana/controllers/productos_controller.dart';
import 'package:provider/provider.dart';
import 'package:podologia_sana/views/dashboard_admin/estadisticasA_view.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DoctoresController()),
        ChangeNotifierProvider(create: (_) => PacientesController()),
        ChangeNotifierProvider(create: (_) => ProductosController()),
        // Aquí puedes agregar más controllers en el futuro
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Podología Sana',
      initialRoute: AppRoutes.dashboard_admin,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
    );
  }
}
