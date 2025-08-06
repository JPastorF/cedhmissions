// lib/data/mission_plans.dart
import '../models/mission.dart'; // Asegúrate de importar tu modelo Mission

class MissionPlans {
  static List<Mission> get basicMissionPlan {
    return [
      Mission(
        id: 'm1_unique_first_blood',
        name: 'Primera Sangre',
        description: 'Ser el primero en completar una acción clave.',
        points: 50,
        type: MissionType.unique,
      ),
      Mission(
        id: 'm2_multiple_resource_gatherer',
        name: 'Recolector Novato',
        description: 'Recolectar 5 unidades de recurso básico.',
        points: 20,
        type: MissionType.multiple,
      ),
      Mission(
        id: 'm3_multiple_unexpected_loss',
        name: 'Pérdida Inesperada',
        description: 'Sufrir una penalización por un evento aleatorio.',
        points: -10,
        type: MissionType.multiple,
      ),
    ];
  }

  static List<Mission> get advancedMissionPlan {
    return [
      Mission(
        id: 'm4_unique_zone_dominator',
        name: 'Dominador de Zona',
        description: 'Controlar una zona estratégica durante toda la ronda.',
        points: 100,
        type: MissionType.unique,
      ),
      Mission(
        id: 'm5_multiple_brave_explorer',
        name: 'Explorador Valiente',
        description: 'Descubrir 3 nuevas áreas del mapa.',
        points: 30,
        type: MissionType.multiple,
      ),
      Mission(
        id: 'm6_unique_deadly_trap',
        name: 'Trampa Mortal',
        description:
            'Activar una trampa que afecta negativamente a un oponente.',
        points: -25,
        type: MissionType.unique,
      ),
      Mission(
        id: 'm7_multiple_teammate_aid',
        name: 'Ayuda al Compañero',
        description: 'Asistir a un compañero en apuros.',
        points: 15,
        type: MissionType.multiple,
      ),
    ];
  }
}
