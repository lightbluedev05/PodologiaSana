import 'package:flutter/material.dart';
import 'dart:async';
import '../views/dashboard_admin_view.dart';
import '../data/usuario_data.dart';
import '../models/usuario_model.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final UsuarioData _usuarioData = UsuarioData();

  void login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Por favor, completa ambos campos.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final usuario = Usuario(username: email, password: password);
      final loggedUser = await _usuarioData.loginUsuario(usuario);

      Navigator.of(context).pop(); // Cierra el loading

      if (loggedUser.rol.toLowerCase() == 'administrador') {
        _navigateWithSlideAnimation(context, const DashboardAdminView());
      } else if (loggedUser.rol.toLowerCase() == 'doctor') {
        //_navigateWithSlideAnimation(context, const DashboardDoctoraView());
      } else {
        _showErrorDialog(context, 'Rol no reconocido: ${loggedUser.rol}');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el loading
      _showErrorDialog(context, 'Error al iniciar sesión:\n${e.toString()}');
    }
  }

  void _navigateWithSlideAnimation(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
