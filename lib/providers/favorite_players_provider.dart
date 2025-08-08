// lib/providers/favorite_players_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../services/storage_service.dart';

/// Provider que gestiona la lista de jugadores favoritos y su persistencia.
///
/// Este proveedor carga la lista de jugadores favoritos desde el almacenamiento
/// local al inicio de la aplicación y la guarda automáticamente cada vez que
/// se realiza un cambio.
class FavoritePlayersProvider with ChangeNotifier {
  // Servicio para guardar y cargar los datos
  final StorageService _storageService = StorageService();
  // Generador de IDs únicos para los jugadores
  final Uuid _uuid = const Uuid();

  // La lista interna de jugadores
  List<Player> _favoritePlayers = [];

  // Getter para acceder a la lista de jugadores favoritos
  List<Player> get favoritePlayers => _favoritePlayers;

  // Constructor que inicia la carga de datos
  FavoritePlayersProvider() {
    _loadPlayers();
  }

  /// Carga la lista de jugadores desde el almacenamiento local.
  Future<void> _loadPlayers() async {
    _favoritePlayers = await _storageService.loadPlayers();
    notifyListeners();
  }

  /// Guarda la lista actual de jugadores en el almacenamiento local.
  Future<void> _savePlayers() async {
    await _storageService.savePlayers(_favoritePlayers);
  }

  /// Añade un nuevo jugador a la lista de favoritos.
  /// Ahora crea un objeto Player completo con un ID único.
  void addFavoritePlayer(String playerName) {
    if (playerName.trim().isNotEmpty &&
        !_favoritePlayers.any((player) => player.name == playerName)) {
      _favoritePlayers.add(Player(id: _uuid.v4(), name: playerName));
      _savePlayers();
      notifyListeners();
    }
  }

  /// Elimina un jugador de la lista de favoritos usando su ID único.
  /// Eliminar por ID es más robusto que por nombre.
  void removeFavoritePlayer(String playerId) {
    _favoritePlayers.removeWhere((player) => player.id == playerId);
    _savePlayers();
    notifyListeners();
  }

  /// Actualiza el nombre de un jugador favorito usando su ID único.
  /// Se ha cambiado la firma del método para ser más robusta.
  void updateFavoritePlayerName(String playerId, String newName) {
    // 1. Limpiamos el nuevo nombre de espacios en blanco al inicio y al final.
    final trimmedNewName = newName.trim();

    // 2. Verificamos si el nuevo nombre no está vacío.
    if (trimmedNewName.isEmpty) {
      // Aquí puedes añadir un mensaje de error si el nombre está vacío.
      return;
    }

    // 3. Comprobamos si ya existe un jugador favorito con este nombre,
    //    excluyendo al jugador que se está editando.
    final isDuplicate = _favoritePlayers.any(
      (p) =>
          p.id != playerId &&
          p.name.trim().toLowerCase() == trimmedNewName.toLowerCase(),
    );

    // 4. Si se encuentra un duplicado, detenemos la operación.
    if (isDuplicate) {
      // Puedes añadir lógica para mostrar un mensaje de error al usuario,
      // por ejemplo, usando un Snackbar.
      //print('Error: Ya existe un jugador favorito con este nombre.');
      return;
    }

    // 5. Si no hay duplicados, buscamos el jugador y actualizamos su nombre.
    final index = _favoritePlayers.indexWhere(
      (player) => player.id == playerId,
    );

    if (index != -1) {
      _favoritePlayers[index].name = trimmedNewName;
      _savePlayers();
      notifyListeners();
    }
  }
}
