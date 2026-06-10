class Exercise {
  final int? id;
  final String name;
  final String category;
  final String muscleGroup;
  final String equipment;
  final bool isCustom;
  // Sync metadata
  final String? uuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

  Exercise({
    this.id,
    required this.name,
    required this.category,
    this.muscleGroup = '',
    this.equipment = '',
    this.isCustom = false,
    this.uuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    String? muscleGroup,
    String? equipment,
    bool? isCustom,
    String? uuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      isCustom: isCustom ?? this.isCustom,
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'isCustom': isCustom ? 1 : 0,
      'uuid': uuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
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
      uuid: map['uuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
