import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/time_entry.dart';
import '../services/storage_service.dart';

class EntryProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<TimeEntry> _entries = [];
  bool _isLoaded = false;

  List<TimeEntry> get entries => List.unmodifiable(_entries);
  bool get isLoaded => _isLoaded;

  /// Load entries from local storage
  Future<void> loadEntries() async {
    _entries = await _storage.loadTimeEntries();
    _isLoaded = true;
    notifyListeners();
  }

  /// Add a new time entry
  Future<void> addEntry({
    required String projectId,
    required String taskId,
    required double totalTime,
    required String notes,
    required DateTime date,
  }) async {
    final entry = TimeEntry(
      id: const Uuid().v4(),
      projectId: projectId,
      taskId: taskId,
      totalTime: totalTime,
      notes: notes,
      date: date,
    );
    _entries.add(entry);
    await _storage.saveTimeEntries(_entries);
    notifyListeners();
  }

  /// Delete an entry by id
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _storage.saveTimeEntries(_entries);
    notifyListeners();
  }

  /// Clear all entries
  Future<void> clearEntries() async {
    _entries.clear();
    await _storage.saveTimeEntries(_entries);
    notifyListeners();
  }

  /// Get entries grouped by project id
  Map<String, List<TimeEntry>> entriesByProject() {
    final Map<String, List<TimeEntry>> grouped = {};
    for (final entry in _entries) {
      grouped.putIfAbsent(entry.projectId, () => []).add(entry);
    }
    return grouped;
  }
}
