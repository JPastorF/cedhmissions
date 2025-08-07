// lib/providers/mission_plan_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mission_plan.dart';
import '../models/mission.dart';

/// Provider que gestiona los planes de misiones y las misiones individuales.
class MissionPlanProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<MissionPlan> _missionPlans = [];

  /// Getter para obtener la lista de planes de misiones.
  List<MissionPlan> get missionPlans => _missionPlans;

  /// Constructor del provider que carga los datos iniciales.
  MissionPlanProvider() {
    _loadInitialData();
  }

  /// Carga datos ficticios para el inicio de la aplicación.
  /// Esto simula tener planes y misiones ya creados.
  void _loadInitialData() {
    _missionPlans = [
      MissionPlan(
        id: _uuid.v4(),
        name: 'Plan Básico',
        missions: [
          // Ejemplo de misión con descripción
          Mission(
            id: _uuid.v4(),
            name: 'Recoger 10 items',
            description: 'Misión 1 (Básica)',
            points: 100,
            type: MissionType.multiple,
          ),
          // Ejemplo de misión sin descripción
          Mission(
            id: _uuid.v4(),
            name: 'Encontrar el tesoro',
            points: 200,
            type: MissionType.unique,
          ),
        ],
      ),
      MissionPlan(
        id: _uuid.v4(),
        name: 'Plan Avanzado',
        missions: [
          Mission(
            id: _uuid.v4(),
            name: 'Derrotar al jefe final',
            description: 'Misión 1 (Avanzado)',
            points: 150,
            type: MissionType.multiple,
          ),
          Mission(
            id: _uuid.v4(),
            name: 'Completar el mapa',
            description: 'Misión 2 (Avanzado)',
            points: 250,
            type: MissionType.unique,
          ),
          Mission(
            id: _uuid.v4(),
            name: 'Descifrar el código',
            description: 'Misión 3 (Avanzado)',
            points: 300,
            type: MissionType.multiple,
          ),
        ],
      ),
    ];
  }

  /// Métodos de gestión de planes
  // Añade un nuevo plan de misión con el nombre dado.
  void addMissionPlan(String name) {
    _missionPlans.add(MissionPlan(id: _uuid.v4(), name: name, missions: []));
    notifyListeners();
  }

  // Actualiza el nombre de un plan de misión existente.
  void updateMissionPlanName(String planId, String newName) {
    final plan = _missionPlans.firstWhere((p) => p.id == planId);
    plan.name = newName;
    notifyListeners();
  }

  // Elimina un plan de misión por su ID.
  void removeMissionPlan(String planId) {
    _missionPlans.removeWhere((plan) => plan.id == planId);
    notifyListeners();
  }

  /// Métodos de gestión de misiones dentro de un plan
  // Añade una nueva misión a un plan específico.
  // El campo `description` ahora es opcional (`String?`).
  void addMissionToPlan(
    String planId,
    String name,
    String? description,
    int points,
    MissionType type,
  ) {
    final plan = _missionPlans.firstWhere((p) => p.id == planId);
    plan.missions.add(
      Mission(
        id: _uuid.v4(),
        name: name,
        description: description,
        points: points,
        type: type,
      ),
    );
    notifyListeners();
  }

  // Actualiza una misión existente dentro de un plan.
  // El campo `description` ahora es opcional (`String?`).
  void updateMissionInPlan(
    String planId,
    String missionId,
    String name,
    String? description,
    int points,
    MissionType type,
  ) {
    final plan = _missionPlans.firstWhere((p) => p.id == planId);
    final mission = plan.missions.firstWhere((m) => m.id == missionId);
    mission.name = name;
    mission.description = description;
    mission.points = points;
    mission.type = type;
    notifyListeners();
  }

  // Elimina una misión de un plan específico.
  void removeMissionFromPlan(String planId, String missionId) {
    final plan = _missionPlans.firstWhere((p) => p.id == planId);
    plan.missions.removeWhere((mission) => mission.id == missionId);
    notifyListeners();
  }

  // Reordena las misiones dentro de un plan.
  void reorderMissionsInPlan(String planId, int oldIndex, int newIndex) {
    final plan = _missionPlans.firstWhere((p) => p.id == planId);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final Mission mission = plan.missions.removeAt(oldIndex);
    plan.missions.insert(newIndex, mission);
    notifyListeners();
  }
}
