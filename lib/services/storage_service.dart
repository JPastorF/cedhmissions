// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mission_plan.dart';
import '../models/player.dart';
import '../models/game.dart';
import 'package:uuid/uuid.dart';

/// Servicio de persistencia para guardar y cargar el estado completo de la aplicación.
/// Utiliza SharedPreferences para almacenar los datos en formato JSON.
class StorageService {
  static const _missionPlansKey = 'missionPlans';
  static const _playersKey = 'players';
  static const _gameStateKey = 'gameState';
  final Uuid _uuid = Uuid();

  /// Guarda la lista de planes de misiones en el almacenamiento local.
  Future<void> saveMissionPlans(List<MissionPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = plans
        .map((plan) => json.encode(plan.toJson()))
        .toList();
    await prefs.setStringList(_missionPlansKey, jsonList);
  }

  /// Carga la lista de planes de misiones desde el almacenamiento local.
  Future<List<MissionPlan>> loadMissionPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_missionPlansKey);
    if (jsonList == null) {
      return [];
    }
    return jsonList
        .map((jsonString) => MissionPlan.fromJson(json.decode(jsonString)))
        .toList();
  }

  /// Guarda la lista de jugadores en el almacenamiento local.
  Future<void> savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = players
        .map((player) => json.encode(player.toJson()))
        .toList();
    await prefs.setStringList(_playersKey, jsonList);
  }

  /// Carga la lista de jugadores desde el almacenamiento local.
  Future<List<Player>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_playersKey);
    if (jsonList == null) {
      return [];
    }
    return jsonList
        .map((jsonString) => Player.fromJson(json.decode(jsonString)))
        .toList();
  }

  /// Guarda el estado de la partida actual en el almacenamiento local.
  Future<void> saveGameState(Game? game) async {
    final prefs = await SharedPreferences.getInstance();
    if (game != null) {
      await prefs.setString(_gameStateKey, json.encode(game.toJson()));
    } else {
      await prefs.remove(_gameStateKey);
    }
  }

  /// Carga el estado de la partida actual desde el almacenamiento local.
  Future<Game?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_gameStateKey);
    if (jsonString == null) {
      return Game(id: _uuid.v4());
    }
    return Game.fromJson(json.decode(jsonString));
  }
}
