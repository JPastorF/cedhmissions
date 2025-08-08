// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'favorite_players_screen.dart';
import 'mission_plans_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos un degradado para el fondo que se ajuste a tu tema oscuro.
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color(0xFF263238), // blueGrey.shade900
        Color(0xFF37474F), // blueGrey.shade800
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Puntos & Misiones'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExpandedOption(
              context,
              title: 'Iniciar o Continuar Partida',
              icon: Icons.sports_esports,
              color: Colors.blue.shade800, // Un azul profundo
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
            ),
            _buildExpandedOption(
              context,
              title: 'Gestionar Jugadores',
              icon: Icons.person_add_alt_1,
              color: Colors.deepOrange.shade900, // Un naranja oscuro
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoritePlayersScreen(),
                  ),
                );
              },
            ),
            _buildExpandedOption(
              context,
              title: 'Gestionar Planes de Misiones',
              icon: Icons.assignment,
              color: Colors.purple.shade800, // Un púrpura oscuro
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MissionPlansScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 60, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
