import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_players_provider.dart';

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
                  provider.updateFavoritePlayerName(oldName, controller.text);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jugadores Favoritos'),
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
      body: Consumer<FavoritePlayersProvider>(
        builder: (context, provider, child) {
          final players = provider.favoritePlayers;
          return players.isEmpty
              ? const Center(child: Text('No hay jugadores favoritos aún.'))
              : ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final playerName = players[index];
                    return ListTile(
                      title: Text(playerName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditPlayerDialog(
                              context,
                              provider,
                              playerName,
                            ),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                provider.removeFavoritePlayer(playerName),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
