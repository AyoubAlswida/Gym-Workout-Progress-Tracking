class ProgressPhoto {
  final int? id;
  final String date;
  final String filePath;
  final String? note;

  ProgressPhoto({
    this.id,
    required this.date,
    required this.filePath,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'filePath': filePath,
      'note': note,
    };
  }

  factory ProgressPhoto.fromMap(Map<String, dynamic> map) {
    return ProgressPhoto(
      id: map['id'],
      date: map['date'],
      filePath: map['filePath'],
      note: map['note'],
    );
  }
}
