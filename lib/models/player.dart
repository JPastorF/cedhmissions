class Player {
  String id; // Identificador único para el jugador
  String name;
  int totalPoints; // Puntos acumulados del jugador

  Player({required this.id, required this.name, this.totalPoints = 0});

  // Método para actualizar los puntos del jugador
  void addPoints(int points) {
    totalPoints += points;
  }

  // Convertir a mapa (útil para persistencia futura)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'totalPoints': totalPoints};
  }

  // Crear desde un mapa
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      totalPoints: json['totalPoints'] ?? 0,
    );
  }
}
