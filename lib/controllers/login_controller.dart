import 'package:flutter/material.dart';
import 'dart:async';
import '../views/dashboard_admin_view.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Por favor, completa ambos campos.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));

    Navigator.of(context).pop();

    if (email == 'admin' && password == 'admin') {
      _navigateWithSlideAnimation(context, const DashboardAdminView());
    } else if (email == 'doc' && password == 'doc') {
      // _navigateWithSlideAnimation(context, const DashboardDoctoraView());
    } else {
      _showErrorDialog(context, 'Credenciales incorrectas');
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