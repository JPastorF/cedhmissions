import 'package:flutter/material.dart';

// Este provider gestiona una lista de nombres de jugadores favoritos.
class FavoritePlayersProvider with ChangeNotifier {
  final List<String> _favoritePlayers = []; // Datos de ejemplo

  List<String> get favoritePlayers => _favoritePlayers;

  // Añade un nuevo jugador a la lista de favoritos.
  void addFavoritePlayer(String playerName) {
    if (playerName.isNotEmpty && !_favoritePlayers.contains(playerName)) {
      _favoritePlayers.add(playerName);
      // Notifica a los oyentes (como FavoritePlayersScreen) que la lista ha cambiado.
      notifyListeners();
    }
  }

  // Elimina un jugador de la lista de favoritos.
  void removeFavoritePlayer(String playerName) {
    _favoritePlayers.remove(playerName);
    // Notifica a los oyentes que la lista ha cambiado.
    notifyListeners();
  }

  // Actualiza el nombre de un jugador favorito.
  void updateFavoritePlayerName(String oldName, String newName) {
    final index = _favoritePlayers.indexOf(oldName);
    if (index != -1 && newName.isNotEmpty) {
      _favoritePlayers[index] = newName;
      // Notifica a los oyentes que la lista ha cambiado.
      notifyListeners();
    }
  }
}
