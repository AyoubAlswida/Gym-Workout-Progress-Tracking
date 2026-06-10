class ProgressPhoto {
  final int? id;
  final String date;
  final String filePath;
  final String? note;
  // Sync metadata
  final String? uuid;
  final String? updatedAt;
  final bool isDirty;
  final bool isDeleted;

  ProgressPhoto({
    this.id,
    required this.date,
    required this.filePath,
    this.note,
    this.uuid,
    this.updatedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  ProgressPhoto copyWith({
    int? id,
    String? date,
    String? filePath,
    String? note,
    String? uuid,
    String? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return ProgressPhoto(
      id: id ?? this.id,
      date: date ?? this.date,
      filePath: filePath ?? this.filePath,
      note: note ?? this.note,
      uuid: uuid ?? this.uuid,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'filePath': filePath,
      'note': note,
      'uuid': uuid,
      'updatedAt': updatedAt,
      'isDirty': isDirty ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) {
    return ProgressPhoto(
      id: map['id'],
      date: map['date'],
      filePath: map['filePath'],
      note: map['note'],
      uuid: map['uuid'],
      updatedAt: map['updatedAt'],
      isDirty: map['isDirty'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }
}
