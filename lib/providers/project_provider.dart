import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

class ProjectProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Project> _projects = [];
  bool _isLoaded = false;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoaded => _isLoaded;

  /// Load projects from local storage
  Future<void> loadProjects() async {
    _projects = await _storage.loadProjects();
    _isLoaded = true;
    notifyListeners();
  }

  /// Add a new project
  Future<void> addProject(String title) async {
    final project = Project(
      id: const Uuid().v4(),
      title: title.trim(),
    );
    _projects.add(project);
    await _storage.saveProjects(_projects);
    notifyListeners();
  }

  /// Delete a project by id
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await _storage.saveProjects(_projects);
    notifyListeners();
  }

  /// Find a project by id
  Project? findById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get project title by id (fallback to 'Unknown')
  String getTitle(String id) => findById(id)?.title ?? 'Unknown Project';
}
