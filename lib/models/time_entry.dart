class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime; // in hours
  final String notes;
  final DateTime date;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'taskId': taskId,
        'totalTime': totalTime,
        'notes': notes,
        'date': date.toIso8601String(),
      };

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        taskId: json['taskId'] as String,
        totalTime: (json['totalTime'] as num).toDouble(),
        notes: json['notes'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  @override
  String toString() =>
      'TimeEntry(id: $id, projectId: $projectId, taskId: $taskId, '
      'totalTime: $totalTime, date: $date)';
}
