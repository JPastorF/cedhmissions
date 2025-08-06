import 'mission.dart';

class Round {
  String id; // Identificador único para la ronda
  int roundNumber; // Número de la ronda (1, 2, 3...)
  List<Mission> missions; // Lista de misiones para esta ronda
  // Mapa para rastrear qué jugadores completaron qué misión en esta ronda
  // Clave: ID de la misión, Valor: Lista de IDs de jugadores que la completaron
  Map<String, List<String>> completedMissionsByPlayer;

  Round({
    required this.id,
    required this.roundNumber,
    required this.missions,
    Map<String, List<String>>? completedMissionsByPlayer,
  }) : this.completedMissionsByPlayer = completedMissionsByPlayer ?? {};

  // Marcar una misión como completada por un jugador
  void markMissionCompleted(String missionId, String playerId) {
    if (!completedMissionsByPlayer.containsKey(missionId)) {
      completedMissionsByPlayer[missionId] = [];
    }
    if (!completedMissionsByPlayer[missionId]!.contains(playerId)) {
      completedMissionsByPlayer[missionId]!.add(playerId);
    }
  }

  // Desmarcar una misión para un jugador
  void unmarkMissionCompleted(String missionId, String playerId) {
    completedMissionsByPlayer[missionId]?.remove(playerId);
    // Opcional: limpiar la entrada si la lista de jugadores está vacía
    if (completedMissionsByPlayer[missionId]?.isEmpty ?? false) {
      completedMissionsByPlayer.remove(missionId);
    }
  }

  // Verificar si una misión fue completada por un jugador
  bool isMissionCompletedByPlayer(String missionId, String playerId) {
    return completedMissionsByPlayer[missionId]?.contains(playerId) ?? false;
  }

  // Convertir a mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roundNumber': roundNumber,
      'missions': missions.map((m) => m.toJson()).toList(),
      'completedMissionsByPlayer': completedMissionsByPlayer,
    };
  }

  // Crear desde un mapa
  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'],
      roundNumber: json['roundNumber'],
      missions: (json['missions'] as List)
          .map((mJson) => Mission.fromJson(mJson))
          .toList(),
      completedMissionsByPlayer:
          (json['completedMissionsByPlayer'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
    );
  }
}
