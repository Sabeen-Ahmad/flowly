class Task {
  final String id;
  final String name;
  final String title;
  final String description;
  final String status;
  final String dueDate;


  Task({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,

  });

  /// API → Model
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: json['due_date'] ?? '',

    );
  }

  /// Model → API
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'due_date': dueDate,
    };
  }

  /// Model → SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate,

    };
  }

  /// SQLite → Model
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      dueDate: map['dueDate'] ?? '',

    );
  }
}