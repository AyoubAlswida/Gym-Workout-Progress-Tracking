class Routine {
  final int? id;
  final String name;
  final bool isPreset;
  // Sync metadata
  final String? uuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

  Routine({
    this.id,
    required this.name,
    this.isPreset = false,
    this.uuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  Routine copyWith({
    int? id,
    String? name,
    bool? isPreset,
    String? uuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      isPreset: isPreset ?? this.isPreset,
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
      'isPreset': isPreset ? 1 : 0,
      'uuid': uuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      isPreset: map['isPreset'] == 1,
      uuid: map['uuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
