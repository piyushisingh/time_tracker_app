class Task {
  final String id;
  final String title;
  final String projectId;

  Task({
    required this.id,
    required this.title,
    required this.projectId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'projectId': projectId,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        projectId: json['projectId'] as String,
      );

  @override
  String toString() => 'Task(id: $id, title: $title, projectId: $projectId)';
}
