class Routine {
  final int? id;
  final String name;
  final bool isPreset;

  Routine({
    this.id,
    required this.name,
    this.isPreset = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isPreset': isPreset ? 1 : 0,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      isPreset: map['isPreset'] == 1,
    );
  }
}
