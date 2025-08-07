// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/favorite_players_provider.dart';
import 'providers/mission_plan_provider.dart'; // Importa el nuevo provider
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Se registran todos los providers que se necesitan en la aplicación
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => FavoritePlayersProvider()),
        ChangeNotifierProvider(
          create: (_) => MissionPlanProvider(),
        ), // Añade el nuevo provider aquí
      ],
      child: MaterialApp(
        title: 'Misionero App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(), // La nueva pantalla de inicio
      ),
    );
  }
}
