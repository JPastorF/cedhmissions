// lib/widgets/player_score_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../screens/round_detail_screen.dart'; // Importaremos esta pantalla más tarde

class PlayerScoreCard extends StatelessWidget {
  final Player player;
  final GameProvider gameProvider; // Necesitamos el provider para las acciones

  const PlayerScoreCard({
    super.key,
    required this.player,
    required this.gameProvider,
  });

  void _showEditPlayerDialog(BuildContext context) {
    final TextEditingController _editNameController = TextEditingController(
      text: player.name,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Jugador'),
          content: TextField(
            controller: _editNameController,
            decoration: const InputDecoration(hintText: 'Nuevo nombre'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editNameController.text.isNotEmpty) {
                  gameProvider.updatePlayerName(
                    player.id,
                    _editNameController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showRemovePlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Jugador'),
          content: Text(
            '¿Estás seguro de que quieres eliminar a ${player.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                gameProvider.removePlayer(player.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las rondas para mostrar el desglose
    final game = gameProvider.currentGame;
    final rounds = game?.rounds ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16.0,
          10.0,
          16.0,
          1.0,
        ), // Reducido de 16.0/12.0 a 10.0 en top/bottom
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${player.totalPoints}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: player.totalPoints >= 0
                        ? Colors.greenAccent
                        : Colors.amberAccent,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditPlayerDialog(context);
                    } else if (value == 'delete') {
                      _showRemovePlayerDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar nombre'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar jugador',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const Divider(height: 4, thickness: 1),
            // Desglose de puntos por ronda
            if (rounds.isNotEmpty) ...[
              //const SizedBox(height: 8),
              // Usamos un ListView.builder anidado para el desglose de rondas
              // Asegúrate de que no haya problemas de scroll si la lista es muy larga
              ListView.builder(
                shrinkWrap:
                    true, // Importante para que el ListView anidado no ocupe todo el espacio
                physics:
                    const NeverScrollableScrollPhysics(), // Deshabilita el scroll propio
                itemCount: rounds.length,
                itemBuilder: (context, roundIndex) {
                  final round = rounds[roundIndex];
                  final pointsInRound =
                      gameProvider.currentGame!.playerPointsPerRound[round
                          .id]?[player.id] ??
                      0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ronda ${round.roundNumber}:',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '$pointsInRound',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: pointsInRound >= 0
                                ? Colors.greenAccent
                                : Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              const Text(
                'No hay rondas aún.',
                style: TextStyle(fontSize: 14), //color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
