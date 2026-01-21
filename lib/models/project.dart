class Project {
  final String id;
  final String title;

  Project({
    required this.id,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        title: json['title'] as String,
      );

  @override
  String toString() => 'Project(id: $id, title: $title)';
}
