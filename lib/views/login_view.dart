import 'dart:ui'; // Necesario para ImageFilter

import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';



class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();

  final String fondoLogin = 'res/images/fondoLogin.png';
  final String logo = 'res/images/logo.svg';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    _controller.login(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          SizedBox.expand(
            child: Image.asset(
              fondoLogin,
              fit: BoxFit.cover,
            ),
          ),

          // Filtro de desenfoque
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.2), // Opcional: oscurece un poco
              ),
            ),
          ),

          // Contenido centrado
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppColors.celesteSuave.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      color: AppColors.azulProfundo,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Aquí la imagen logo
                  SvgPicture.asset(
                    logo,
                    color: Colors.white,
                    height: 240, // Puedes ajustar tamaño
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario',
                          style: TextStyle(
                            color: AppColors.azulProfundo,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(),
                          style: TextStyle(
                            color: AppColors.azulProfundo,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contraseña',
                          style: TextStyle(
                            color: AppColors.azulProfundo,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _controller.passwordController,
                          obscureText: true,
                          decoration: _inputDecoration(),
                          style: TextStyle(
                            color: AppColors.azulProfundo,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azulMedio,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.azulMedio, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.azulMedio, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.azulClaro, width: 2),
      ),
    );
  }
}