// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/round.dart';
import '../widgets/player_score_card.dart';
import 'round_detail_screen.dart'; // Asegúrate de importar RoundDetailScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.currentGame == null) {
        gameProvider.newGame();
      }
    });
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Jugador'),
          content: TextField(
            controller: _playerNameController,
            decoration: const InputDecoration(hintText: 'Nombre del jugador'),
            autofocus: true,
            onSubmitted: (name) {
              if (name.isNotEmpty) {
                Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).addPlayer(name);
                _playerNameController.clear();
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playerNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_playerNameController.text.isNotEmpty) {
                  Provider.of<GameProvider>(
                    context,
                    listen: false,
                  ).addPlayer(_playerNameController.text);
                  _playerNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  void _showResetGameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reiniciar Partida'),
          content: const Text(
            '¿Estás seguro de que quieres reiniciar la partida actual? Se perderán todos los datos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<GameProvider>(context, listen: false).resetGame();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Reiniciar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para confirmar la adición de una nueva ronda
  void _showAddRoundConfirmationDialog(
    BuildContext context,
    GameProvider gameProvider,
  ) {
    if (gameProvider.currentGame == null ||
        gameProvider.currentGame!.players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos un jugador antes de crear una ronda.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Nueva Ronda'),
          content: const Text(
            '¿Estás seguro de que quieres añadir una nueva ronda a la partida?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                gameProvider.addRound();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ronda ${gameProvider.currentGame!.rounds.length} añadida.',
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final game = gameProvider.currentGame;
        final players = game?.players ?? [];
        final rounds = game?.rounds ?? []; // Obtener la lista de rondas
        players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Score Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: 'Añadir Jugador',
                onPressed: _showAddPlayerDialog,
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add),
                tooltip: 'Añadir Ronda',
                onPressed: () =>
                    _showAddRoundConfirmationDialog(context, gameProvider),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reiniciar Partida',
                onPressed: _showResetGameDialog,
              ),
            ],
          ),
          body: game == null || players.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay jugadores en la partida.',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showAddPlayerDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Añadir Primer Jugador'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  // Usamos un Row para dividir la pantalla en dos secciones
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // Sección izquierda para la lista de jugadores
                      flex: 3, // Ocupa 3 partes del espacio disponible
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return PlayerScoreCard(
                            player: player,
                            gameProvider: gameProvider,
                          );
                        },
                      ),
                    ),
                    // Separador visual
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                    Expanded(
                      // Sección derecha para la lista de rondas
                      flex: 1, // Ocupa 1 parte del espacio disponible
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rondas:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (rounds.isEmpty)
                              const Text(
                                'No hay rondas aún.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.builder(
                                  itemCount: rounds.length,
                                  itemBuilder: (context, index) {
                                    final round = rounds[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RoundDetailScreen(
                                                    roundId: round.id,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          backgroundColor:
                                              Colors.blueAccent.shade100,
                                          foregroundColor:
                                              Colors.blueGrey.shade900,
                                        ),
                                        child: Text(
                                          'Ronda ${round.roundNumber}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
