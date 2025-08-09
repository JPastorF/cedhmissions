// lib/screens/favorite_players_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_players_provider.dart';
import '../models/player.dart';

class FavoritePlayersScreen extends StatelessWidget {
  const FavoritePlayersScreen({super.key});

  // Diálogo para añadir un nuevo jugador favorito
  void _showAddPlayerDialog(
    BuildContext context,
    FavoritePlayersProvider provider,
  ) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Jugador Favorito'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre del jugador'),
            autofocus: true,
            onSubmitted: (name) {
              if (name.isNotEmpty) {
                provider.addFavoritePlayer(name);
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  provider.addFavoritePlayer(controller.text);
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

  // Diálogo para editar el nombre de un jugador favorito
  void _showEditPlayerDialog(
    BuildContext context,
    FavoritePlayersProvider provider,
    String playerId,
    String oldName,
  ) {
    final TextEditingController controller = TextEditingController(
      text: oldName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Jugador Favorito'),
          content: TextField(
            controller: controller,
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
                if (controller.text.isNotEmpty) {
                  provider.updateFavoritePlayerName(playerId, controller.text);
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

  @override
  Widget build(BuildContext context) {
    // Definimos el degradado de fondo, igual que en HomeScreen
    const LinearGradient backgroundGradient = LinearGradient(
      colors: [
        Color(0xFF263238), // blueGrey.shade900
        Color(0xFF37474F), // blueGrey.shade800
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugadores'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Añadir Jugador',
            onPressed: () => _showAddPlayerDialog(
              context,
              Provider.of<FavoritePlayersProvider>(context, listen: false),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: Consumer<FavoritePlayersProvider>(
          builder: (context, provider, child) {
            final players = provider.favoritePlayers;
            players.sort((a, b) => a.name.compareTo(b.name));

            if (players.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.white30,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay jugadores favoritos. ¡Añade uno!',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
                bottom: 56.0,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.white70),
                      title: Text(player.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.lightBlue,
                            ),
                            onPressed: () => _showEditPlayerDialog(
                              context,
                              provider,
                              player.id,
                              player.name,
                            ),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.deepOrange,
                            ),
                            onPressed: () =>
                                provider.removeFavoritePlayer(player.id),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
