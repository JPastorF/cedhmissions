import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa la librería provider
import 'providers/game_provider.dart'; // Importa tu GameProvider
import 'screens/home_screen.dart'; // Importa tu HomeScreen

void main() {
  runApp(
    // Envolvemos toda la aplicación con ChangeNotifierProvider
    // Esto hace que GameProvider esté disponible para cualquier widget hijo
    ChangeNotifierProvider(
      create: (context) =>
          GameProvider(), // Creamos una instancia de GameProvider
      child: const MyApp(), // Nuestra aplicación principal
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Missions Tracker ',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Un tema de color agradable
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(), // La pantalla inicial de nuestra aplicación
    );
  }
}
