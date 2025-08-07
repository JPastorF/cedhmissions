// lib/providers/mission_plan_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mission_plan.dart';
import '../models/mission.dart';
import '../services/storage_service.dart';

/// Provider que gestiona los planes de misiones y las misiones individuales.
class MissionPlanProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  final StorageService _storageService = StorageService();
  List<MissionPlan> _missionPlans = [];

  /// Getter para obtener la lista de planes de misiones.
  List<MissionPlan> get missionPlans => _missionPlans;

  /// Constructor del provider que carga los datos iniciales.
  MissionPlanProvider() {
    _loadData();
  }

  /// Carga los planes de misiones desde el almacenamiento local.
  Future<void> _loadData() async {
    _missionPlans = await _storageService.loadMissionPlans();
    notifyListeners();
  }

  /// Guarda la lista actual de planes de misiones.
  Future<void> _saveData() async {
    await _storageService.saveMissionPlans(_missionPlans);
  }

  /// Métodos de gestión de planes
  // Añade un nuevo plan de misión con el nombre dado.
  void addMissionPlan(String name) {
    if (name.trim().isEmpty) return;
    _missionPlans.add(MissionPlan(id: _uuid.v4(), name: name, missions: []));
    _saveData();
    notifyListeners();
  }

  // Actualiza el nombre de un plan de misión existente.
  void updateMissionPlanName(String planId, String newName) {
    try {
      if (newName.trim().isEmpty) return;
      final plan = _missionPlans.firstWhere((p) => p.id == planId);
      plan.name = newName;
      _saveData();
      notifyListeners();
    } catch (e) {
      print('Error: Plan con ID $planId no encontrado.');
    }
  }

  // Elimina un plan de misión por su ID.
  void removeMissionPlan(String planId) {
    _missionPlans.removeWhere((plan) => plan.id == planId);
    _saveData();
    notifyListeners();
  }

  /// Métodos de gestión de misiones dentro de un plan
  // Añade una nueva misión a un plan específico.
  void addMissionToPlan(
    String planId,
    String name,
    String? description,
    int points,
    MissionType type,
  ) {
    try {
      if (name.trim().isEmpty) return;
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
      _saveData();
      notifyListeners();
    } catch (e) {
      print('Error: Plan con ID $planId no encontrado.');
    }
  }

  // Actualiza una misión existente dentro de un plan.
  void updateMissionInPlan(
    String planId,
    String missionId,
    String name,
    String? description,
    int points,
    MissionType type,
  ) {
    try {
      if (name.trim().isEmpty) return;
      final plan = _missionPlans.firstWhere((p) => p.id == planId);
      final mission = plan.missions.firstWhere((m) => m.id == missionId);
      mission.name = name;
      mission.description = description;
      mission.points = points;
      mission.type = type;
      _saveData();
      notifyListeners();
    } catch (e) {
      print('Error: Plan o Misión no encontrados para actualizar.');
    }
  }

  // Elimina una misión de un plan específico.
  void removeMissionFromPlan(String planId, String missionId) {
    try {
      final plan = _missionPlans.firstWhere((p) => p.id == planId);
      plan.missions.removeWhere((mission) => mission.id == missionId);
      _saveData();
      notifyListeners();
    } catch (e) {
      print('Error: Plan con ID $planId no encontrado.');
    }
  }

  // Reordena las misiones dentro de un plan.
  void reorderMissionsInPlan(String planId, int oldIndex, int newIndex) {
    try {
      final plan = _missionPlans.firstWhere((p) => p.id == planId);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Mission mission = plan.missions.removeAt(oldIndex);
      plan.missions.insert(newIndex, mission);
      _saveData();
      notifyListeners();
    } catch (e) {
      print('Error: Plan con ID $planId no encontrado.');
    }
  }
}
