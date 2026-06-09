class Exercise {
  final int? id;
  final String name;
  final String category;
  final String muscleGroup;
  final String equipment;
  final bool isCustom;

  Exercise({
    this.id,
    required this.name,
    required this.category,
    this.muscleGroup = '',
    this.equipment = '',
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      muscleGroup: map['muscleGroup'] ?? '',
      equipment: map['equipment'] ?? '',
      isCustom: map['isCustom'] == 1,
    );
  }
}
