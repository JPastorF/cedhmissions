// lib/models/mission_plan.dart
import 'mission.dart';

class MissionPlan {
  String id;
  String name;
  List<Mission> missions;

  MissionPlan({required this.id, required this.name, required this.missions});

  // Método para convertir el plan a un mapa, serializando también la lista de misiones.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'missions': missions.map((mission) => mission.toJson()).toList(),
    };
  }

  // Método para crear un objeto MissionPlan desde un mapa.
  factory MissionPlan.fromJson(Map<String, dynamic> json) {
    return MissionPlan(
      id: json['id'],
      name: json['name'],
      missions: (json['missions'] as List<dynamic>)
          .map((missionJson) => Mission.fromJson(missionJson))
          .toList(),
    );
  }
}
