import 'player.dart';
import 'round.dart';

class Game {
  String id; // Identificador único para la partida
  List<Player> players;
  List<Round> rounds;
  // Mapa para almacenar los puntos de cada jugador por ronda
  // Clave: ID de la ronda, Valor: Mapa (Clave: ID de jugador, Valor: Puntos en esa ronda)
  Map<String, Map<String, int>> playerPointsPerRound;

  Game({
    required this.id,
    List<Player>? players,
    List<Round>? rounds,
    Map<String, Map<String, int>>? playerPointsPerRound,
  }) : players = players ?? [],
       rounds = rounds ?? [],
       playerPointsPerRound = playerPointsPerRound ?? {};

  // Añadir un nuevo jugador a la partida
  void addPlayer(Player player) {
    players.add(player);
  }

  // Añadir una nueva ronda a la partida
  void addRound(Round round) {
    rounds.add(round);
  }

  // Calcular los puntos totales para un jugador específico
  int calculatePlayerTotalPoints(String playerId) {
    int total = 0;
    for (var round in rounds) {
      if (playerPointsPerRound.containsKey(round.id) &&
          playerPointsPerRound[round.id]!.containsKey(playerId)) {
        total += playerPointsPerRound[round.id]![playerId]!;
      }
    }
    return total;
  }

  // Actualizar los puntos de un jugador para una ronda específica
  void updatePlayerPointsForRound(String roundId, String playerId, int points) {
    if (!playerPointsPerRound.containsKey(roundId)) {
      playerPointsPerRound[roundId] = {};
    }
    playerPointsPerRound[roundId]![playerId] = points;
  }

  // Convertir a mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'players': players.map((p) => p.toJson()).toList(),
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'playerPointsPerRound': playerPointsPerRound,
    };
  }

  // Crear desde un mapa
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      players: (json['players'] as List)
          .map((pJson) => Player.fromJson(pJson))
          .toList(),
      rounds: (json['rounds'] as List)
          .map((rJson) => Round.fromJson(rJson))
          .toList(),
      playerPointsPerRound:
          (json['playerPointsPerRound'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              Map<String, int>.from(value as Map<String, dynamic>),
            ),
          ),
    );
  }
}
