import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class StorageService {
  static const String _projectsKey = 'projects';
  static const String _tasksKey = 'tasks';
  static const String _entriesKey = 'time_entries';

  // ── Projects ──────────────────────────────────────────────────────────

  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_projectsKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, encoded);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  // ── Time Entries ──────────────────────────────────────────────────────

  Future<List<TimeEntry>> loadTimeEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => TimeEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTimeEntries(List<TimeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, encoded);
  }

  // ── Raw Data (for debug screen) ───────────────────────────────────────

  Future<Map<String, String?>> loadRawData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'projects': prefs.getString(_projectsKey),
      'tasks': prefs.getString(_tasksKey),
      'time_entries': prefs.getString(_entriesKey),
    };
  }
}
