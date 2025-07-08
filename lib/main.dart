import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podologia_sana/app_routes.dart';
import 'package:podologia_sana/controllers/doctores_controller.dart';
import 'package:podologia_sana/controllers/pacientes_controller.dart';
import 'package:podologia_sana/controllers/productos_controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DoctoresController()),
        ChangeNotifierProvider(create: (_) => PacientesController()),
        ChangeNotifierProvider(create: (_) => ProductosController()),
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
      initialRoute: AppRoutes.recepcionist,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
    );
  }
}