class Exercise {
  final int? id;
  final String name;
  final String category;

  Exercise({
    this.id,
    required this.name,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      category: map['category'],
    );
  }
}
