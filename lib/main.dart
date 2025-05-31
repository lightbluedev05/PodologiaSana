import 'package:flutter/material.dart';
import 'package:podologia_sana/login.dart';

void main() {
  //runApp(MyApp());
  runApp(const MaterialApp(
    home: LoginScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String texto = "¡Hola Flutter Web!";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba Flutter Web',
      home: Scaffold(
        appBar: AppBar(title: Text('Demo Flutter Web')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(texto, style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Cambiar texto'),
                onPressed: () {
                  setState(() {
                    texto = "¡Funciona!";
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
