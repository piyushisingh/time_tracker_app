import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/entry_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null || _selectedTaskId == null) return;

    setState(() => _isSubmitting = true);

    await context.read<EntryProvider>().addEntry(
          projectId: _selectedProjectId!,
          taskId: _selectedTaskId!,
          totalTime: double.parse(_timeController.text.trim()),
          notes: _notesController.text.trim(),
          date: _selectedDate,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Time entry added successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projects = context.watch<ProjectProvider>().projects;
    final taskProvider = context.watch<TaskProvider>();

    // Tasks filtered by selected project
    final tasks = _selectedProjectId != null
        ? taskProvider.tasksByProject(_selectedProjectId!)
        : <Task>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Time Entry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.5),
                      colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_rounded,
                        color: colorScheme.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Time Entry',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Fill in the details below',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Total Time ────────────────────────────────────────
              TextFormField(
                controller: _timeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total Time (hours)',
                  hintText: 'e.g. 2.5',
                  prefixIcon: const Icon(Icons.schedule_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the time';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Project Dropdown ──────────────────────────────────
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: InputDecoration(
                  labelText: 'Project',
                  prefixIcon: const Icon(Icons.folder_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                ),
                items: projects
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.title),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                    _selectedTaskId = null; // reset task when project changes
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a project' : null,
                hint: const Text('Select a project'),
              ),
              const SizedBox(height: 16),

              // ── Task Dropdown ─────────────────────────────────────
              DropdownButtonFormField<String>(
                value: _selectedTaskId,
                decoration: InputDecoration(
                  labelText: 'Task',
                  prefixIcon: const Icon(Icons.task_alt_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                ),
                items: tasks
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.title),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedTaskId = value);
                },
                validator: (value) =>
                    value == null ? 'Please select a task' : null,
                hint: Text(
                  _selectedProjectId == null
                      ? 'Select a project first'
                      : 'Select a task',
                ),
              ),
              const SizedBox(height: 16),

              // ── Date Picker ───────────────────────────────────────
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(Icons.edit_calendar_rounded,
                          color: colorScheme.primary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Notes ─────────────────────────────────────────────
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any notes about this time entry...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_rounded),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit Button ─────────────────────────────────────
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isSubmitting ? 'Saving...' : 'Save Entry',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
