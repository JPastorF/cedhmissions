enum MissionType {
  unique, // Solo un jugador puede completarla por ronda
  multiple, // Múltiples jugadores pueden completarla por ronda
}

class Mission {
  String id; // Identificador único para la misión
  String name;
  String? description; // Descripción opcional de la misión
  int points; // Puntos que otorga la misión (puede ser negativo)
  MissionType type;

  Mission({
    required this.id,
    required this.name,
    this.description,
    required this.points,
    required this.type,
  });

  // Convertir a mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'points': points,
      'type': type
          .toString()
          .split('.')
          .last, // Guardar como 'unique' o 'multiple'
    };
  }

  // Crear desde un mapa
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      points: json['points'],
      type: MissionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () =>
            MissionType.multiple, // Valor por defecto si no se encuentra
      ),
    );
  }
}
