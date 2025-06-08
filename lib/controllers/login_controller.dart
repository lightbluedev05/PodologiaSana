import 'package:flutter/material.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Por favor, completa ambos campos.');
      return;
    }

    // Simulación de verificación de credenciales y tipo de usuario
    if (email == 'admin' && password == 'admin') {
      Navigator.pushReplacementNamed(context, '/dashboard_admin');
    } else if (email == 'doc' && password == 'doc') {
      Navigator.pushReplacementNamed(context, '/dashboard_doctora');
    } else {
      _showErrorDialog(context, 'Credenciales incorrectas');
    }
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
