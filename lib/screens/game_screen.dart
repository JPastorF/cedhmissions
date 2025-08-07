// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/favorite_players_provider.dart';
import '../models/player.dart';
import '../models/round.dart';
import '../models/mission_plan.dart';
import '../providers/mission_plan_provider.dart';
import '../widgets/player_score_card.dart';
import 'round_detail_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
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

  // Diálogo para añadir jugadores (nuevo o favoritos)
  void _showAddPlayerAndFavoritesDialog(
    BuildContext context,
    GameProvider gameProvider,
  ) {
    _playerNameController.clear();
    final favoritePlayersProvider = Provider.of<FavoritePlayersProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<FavoritePlayersProvider>(
          builder: (context, favProvider, child) {
            final favoritePlayers = favProvider.favoritePlayers;
            final gamePlayerNames =
                gameProvider.currentGame?.players.map((p) => p.name).toSet() ??
                {};
            final selectablePlayers = favoritePlayers
                .where((name) => !gamePlayerNames.contains(name))
                .toList();

            return AlertDialog(
              title: const Text('Añadir Jugadores'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _playerNameController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre del nuevo jugador',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_playerNameController.text.isNotEmpty) {
                          gameProvider.addPlayer(_playerNameController.text);
                          _playerNameController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Añadir Nuevo Jugador'),
                    ),
                    const SizedBox(height: 20),
                    if (selectablePlayers.isNotEmpty) ...[
                      const Text(
                        'O selecciona de favoritos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...selectablePlayers.map((playerName) {
                        return ListTile(
                          title: Text(playerName.name),
                          onTap: () {
                            gameProvider.addPlayer(playerName.name);
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ] else ...[
                      const Text(
                        'No hay jugadores favoritos disponibles para añadir.',
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Diálogo para reiniciar la partida
  void _showResetGameDialog(GameProvider provider) {
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
                provider.resetGame();
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

  // Nuevo diálogo para seleccionar un plan de misiones y añadir una nueva ronda
  void _showAddRoundDialog(BuildContext context, GameProvider gameProvider) {
    if (gameProvider.currentGame == null ||
        gameProvider.currentGame!.players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos un jugador antes de crear una ronda.'),
        ),
      );
      return;
    }

    final missionPlanProvider = Provider.of<MissionPlanProvider>(
      context,
      listen: false,
    );
    final plans = missionPlanProvider.missionPlans;

    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay planes de misiones disponibles. Crea uno primero.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Plan de Misión'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: plans
                  .map(
                    (plan) => ListTile(
                      title: Text(plan.name),
                      onTap: () {
                        gameProvider.addRound(plan);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Ronda ${gameProvider.currentGame!.rounds.length} añadida con el plan "${plan.name}".',
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
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
        final rounds = game?.rounds ?? [];
        players.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Partida'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: 'Añadir Jugador o Importar de Favoritos',
                onPressed: () =>
                    _showAddPlayerAndFavoritesDialog(context, gameProvider),
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add),
                tooltip: 'Añadir Ronda',
                onPressed: () => _showAddRoundDialog(context, gameProvider),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reiniciar Partida',
                onPressed: () => _showResetGameDialog(gameProvider),
              ),
            ],
          ),
          body: game == null || players.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Añade jugadores para comenzar una partida.',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showAddPlayerAndFavoritesDialog(
                          context,
                          gameProvider,
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Añadir Jugadores'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
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
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                    Expanded(
                      flex: 1,
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
