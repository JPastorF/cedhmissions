// lib/providers/game_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Para generar IDs únicos
import '../models/player.dart';
import '../models/mission.dart';
import '../models/mission_plan.dart'; // Importa el modelo de plan de misiones
import '../models/round.dart';
import '../models/game.dart';
// Ya no es necesario importar los datos de planes fijos aquí

class GameProvider with ChangeNotifier {
  Game? _currentGame; // La única partida activa
  final Uuid _uuid = Uuid(); // Generador de IDs únicos

  Game? get currentGame => _currentGame;

  // Inicializa una nueva partida o carga una existente (futuro)
  void newGame() {
    _currentGame = Game(id: _uuid.v4());
    notifyListeners();
  }

  // Reinicia la partida actual
  void resetGame() {
    _currentGame = null;
    notifyListeners();
  }

  // --- Gestión de Jugadores ---

  void addPlayer(String name) {
    if (_currentGame == null) {
      newGame(); // Si no hay partida, crea una nueva
    }
    final newPlayer = Player(id: _uuid.v4(), name: name);
    _currentGame!.addPlayer(newPlayer);
    _recalculateAllPlayerTotalPoints(); // Recalcular totales al añadir jugador
    notifyListeners();
  }

  void removePlayer(String playerId) {
    if (_currentGame == null) return;
    _currentGame!.players.removeWhere((player) => player.id == playerId);
    // También limpiar puntos del jugador en todas las rondas si es necesario
    for (var round in _currentGame!.rounds) {
      _currentGame!.playerPointsPerRound[round.id]?.remove(playerId);
      // Limpiar misiones completadas por este jugador en todas las rondas
      round.completedMissionsByPlayer.forEach((missionId, playerIds) {
        playerIds.remove(playerId);
      });
    }
    _recalculateAllPlayerTotalPoints(); // Recalcular totales al eliminar jugador
    notifyListeners();
  }

  void updatePlayerName(String playerId, String newName) {
    if (_currentGame == null) return;
    final playerIndex = _currentGame!.players.indexWhere(
      (p) => p.id == playerId,
    );
    if (playerIndex != -1) {
      _currentGame!.players[playerIndex].name = newName;
      notifyListeners();
    }
  }

  // --- Gestión de Rondas ---

  // Método actualizado: Ahora acepta un MissionPlan
  void addRound(MissionPlan missionPlan) {
    if (_currentGame == null) {
      newGame(); // Si no hay partida, crea una nueva
    }
    final int newRoundNumber = _currentGame!.rounds.length + 1;
    // Usar las misiones del plan proporcionado
    final List<Mission> missionsForThisRound = List.from(missionPlan.missions);

    final newRound = Round(
      id: _uuid.v4(),
      roundNumber: newRoundNumber,
      missions: missionsForThisRound,
    );
    _currentGame!.addRound(newRound);
    // Inicializar los puntos de los jugadores para esta nueva ronda a 0
    _currentGame!.playerPointsPerRound[newRound.id] = {};
    for (var player in _currentGame!.players) {
      _currentGame!.playerPointsPerRound[newRound.id]![player.id] = 0;
    }

    notifyListeners();
  }

  void removeRound(String roundId) {
    if (_currentGame == null) return;
    _currentGame!.rounds.removeWhere((round) => round.id == roundId);
    _currentGame!.playerPointsPerRound.remove(
      roundId,
    ); // Eliminar los puntos de esa ronda
    _recalculateAllPlayerTotalPoints(); // Recalcular totales
    notifyListeners();
  }

  // --- Lógica de Misiones y Puntos ---

  void toggleMissionCompletion(
    String roundId,
    String missionId,
    String playerId,
  ) {
    if (_currentGame == null) return;

    final round = _currentGame!.rounds.firstWhere((r) => r.id == roundId);
    final mission = round.missions.firstWhere((m) => m.id == missionId);

    bool isCurrentlyCompletedByPlayer = round.isMissionCompletedByPlayer(
      missionId,
      playerId,
    );

    if (isCurrentlyCompletedByPlayer) {
      // Si ya está marcada por este jugador, la desmarcamos
      round.unmarkMissionCompleted(missionId, playerId);
    } else {
      // Si no está marcada por este jugador, la marcamos
      if (mission.type == MissionType.unique) {
        // Para misiones únicas, desmarcamos a cualquier otro jugador que la haya completado
        if (round.completedMissionsByPlayer.containsKey(missionId)) {
          final previousPlayers = List<String>.from(
            round.completedMissionsByPlayer[missionId]!,
          );
          for (var prevPlayerId in previousPlayers) {
            round.unmarkMissionCompleted(missionId, prevPlayerId);
          }
        }
      }
      round.markMissionCompleted(missionId, playerId);
    }

    _recalculateRoundPoints(roundId); // Recalcular puntos para esta ronda
    _recalculateAllPlayerTotalPoints(); // Recalcular puntos totales de todos los jugadores
    notifyListeners();
  }

  // Recalcula los puntos para una ronda específica y actualiza playerPointsPerRound
  void _recalculateRoundPoints(String roundId) {
    if (_currentGame == null) return;

    final round = _currentGame!.rounds.firstWhere((r) => r.id == roundId);
    final Map<String, int> currentRoundPoints = {};

    // Inicializar puntos de todos los jugadores a 0 para esta ronda
    for (var player in _currentGame!.players) {
      currentRoundPoints[player.id] = 0;
    }

    // Iterar sobre las misiones de la ronda
    for (var mission in round.missions) {
      final List<String>? playersCompletedMission =
          round.completedMissionsByPlayer[mission.id];

      if (playersCompletedMission != null &&
          playersCompletedMission.isNotEmpty) {
        if (mission.type == MissionType.unique) {
          // Misión única: solo el primer jugador en la lista obtiene los puntos
          final completingPlayerId = playersCompletedMission.first;
          currentRoundPoints[completingPlayerId] =
              (currentRoundPoints[completingPlayerId] ?? 0) + mission.points;
        } else {
          // Misión múltiple: todos los jugadores en la lista obtienen los puntos
          for (var playerId in playersCompletedMission) {
            currentRoundPoints[playerId] =
                (currentRoundPoints[playerId] ?? 0) + mission.points;
          }
        }
      }
    }
    _currentGame!.playerPointsPerRound[roundId] = currentRoundPoints;
  }

  // Recalcula los puntos totales de todos los jugadores basándose en playerPointsPerRound
  void _recalculateAllPlayerTotalPoints() {
    if (_currentGame == null) return;

    for (var player in _currentGame!.players) {
      int total = 0;
      for (var roundId in _currentGame!.playerPointsPerRound.keys) {
        if (_currentGame!.playerPointsPerRound[roundId]!.containsKey(
          player.id,
        )) {
          total += _currentGame!.playerPointsPerRound[roundId]![player.id]!;
        }
      }
      player.totalPoints =
          total; // Actualizar el totalPoints directamente en el objeto Player
    }
    // No es necesario notifyListeners aquí, ya que se llama después de _recalculateRoundPoints
    // o en los métodos de gestión de jugadores/rondas que ya lo hacen.
  }
}
