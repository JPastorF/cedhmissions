// lib/screens/round_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/round.dart';
import '../models/mission.dart';
import '../models/player.dart'; // Asegúrate de que esta importación sea correcta
import '../providers/game_provider.dart';

// Convertimos RoundDetailScreen a StatefulWidget para gestionar el estado del TextField
class RoundDetailScreen extends StatefulWidget {
  final String? roundId;

  const RoundDetailScreen({super.key, required this.roundId});

  @override
  State<RoundDetailScreen> createState() => _RoundDetailScreenState();
}

class _RoundDetailScreenState extends State<RoundDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = ''; // Estado para almacenar el texto de búsqueda

  @override
  void initState() {
    super.initState();
    // Escucha los cambios en el TextField para actualizar el filtro
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final game = gameProvider.currentGame;

        if (game == null || widget.roundId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de Ronda')),
            body: const Center(
              child: Text('No hay partida activa o ID de ronda inválido.'),
            ),
          );
        }

        final round = game.rounds.firstWhere(
          (r) => r.id == widget.roundId,
          orElse: () => Round(id: '', roundNumber: 0, missions: []),
        );

        if (round.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de Ronda')),
            body: const Center(child: Text('Ronda no encontrada.')),
          );
        }

        final players = List<Player>.from(
          game.players,
        ); // Crear una copia mutable
        players.sort(
          (a, b) => a.name.compareTo(b.name),
        ); // Asegura orden alfabético

        // Filtrar misiones basándose en el texto de búsqueda
        final filteredMissions = round.missions.where((mission) {
          final missionNameLower = mission.name.toLowerCase();
          final searchTextLower = _searchText.toLowerCase();
          final missionDescriptionLower =
              mission.description?.toLowerCase() ??
              ''; // Obtener descripción o cadena vacía

          return missionNameLower.contains(
                searchTextLower,
              ) || // Buscar en el nombre
              missionDescriptionLower.contains(
                searchTextLower,
              ); // O buscar en la descripción
        }).toList();

        return Scaffold(
          appBar: AppBar(title: Text('Ronda ${round.roundNumber}')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo de búsqueda para filtrar misiones
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar misión',
                    hintText: 'Escribe para filtrar misiones...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Espacio después del buscador
                Expanded(
                  child: filteredMissions.isEmpty && _searchText.isNotEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron misiones con ese nombre o descripción.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredMissions.length,
                          itemBuilder: (context, index) {
                            final mission =
                                filteredMissions[index]; // Usamos la lista filtrada
                            // Determina el icono y su color según el tipo de misión
                            IconData typeIcon;
                            Color iconColor;
                            if (mission.type == MissionType.unique) {
                              typeIcon =
                                  Icons.person; // Icono para misión única
                              iconColor = Colors.white;
                            } else {
                              typeIcon =
                                  Icons.group; // Icono para misión múltiple
                              iconColor = Colors.white;
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Icono de tipo de misión antes del nombre
                                        Icon(
                                          typeIcon,
                                          color: iconColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            mission.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Para manejar nombres largos
                                          ),
                                        ),
                                        // Puntos al final de la línea
                                        Text(
                                          '${mission.points}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: mission.points >= 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (mission.description != null &&
                                        mission.description!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          mission.description!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    const Divider(height: 20, thickness: 1),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: players.map((player) {
                                        final isCompleted = round
                                            .isMissionCompletedByPlayer(
                                              mission.id,
                                              player.id,
                                            );
                                        return FilterChip(
                                          label: Text(player.name),
                                          selected: isCompleted,
                                          onSelected: (selected) {
                                            gameProvider
                                                .toggleMissionCompletion(
                                                  round.id,
                                                  mission.id,
                                                  player.id,
                                                );
                                          },
                                          selectedColor: Colors.blue.shade100,
                                          checkmarkColor: Colors.blue.shade700,
                                          labelStyle: TextStyle(
                                            color: isCompleted
                                                ? Colors.blue.shade900
                                                : Colors.white,
                                            fontWeight: isCompleted
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
