import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Task> _tasks = [];
  bool _isLoaded = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoaded => _isLoaded;

  /// Load tasks from local storage
  Future<void> loadTasks() async {
    _tasks = await _storage.loadTasks();
    _isLoaded = true;
    notifyListeners();
  }

  /// Add a new task
  Future<void> addTask(String title, String projectId) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      projectId: projectId,
    );
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Delete a task by id
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  /// Get tasks filtered by project id
  List<Task> tasksByProject(String projectId) =>
      _tasks.where((t) => t.projectId == projectId).toList();

  /// Find a task by id
  Task? findById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get task title by id (fallback to 'Unknown')
  String getTitle(String id) => findById(id)?.title ?? 'Unknown Task';
}
