import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/empty_state.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    final projects = context.read<ProjectProvider>().projects;
    String? selectedProjectId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.add_task_rounded, color: cs.primary),
              const SizedBox(width: 10),
              const Text('Add Task'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Fix login bug',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: cs.surfaceContainerLowest,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedProjectId,
                decoration: InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: cs.surfaceContainerLowest,
                ),
                items: projects
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.title)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedProjectId = v),
                hint: const Text('Select project'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty && selectedProjectId != null) {
                  context.read<TaskProvider>().addTask(title, selectedProjectId!);
                  Navigator.of(ctx).pop();
                }
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final taskProvider = context.watch<TaskProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: tasks.isEmpty
          ? const EmptyState(
              icon: Icons.task_alt_rounded,
              message: 'No tasks yet.',
              submessage: 'Tap + to create your first task.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];
                final projectName = projectProvider.getTitle(t.projectId);
                return Dismissible(
                  key: Key(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_rounded, color: cs.onError, size: 28),
                  ),
                  onDismissed: (_) => taskProvider.deleteTask(t.id),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: cs.secondaryContainer,
                        child: Icon(Icons.task_alt_rounded, color: cs.onSecondaryContainer),
                      ),
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Project: $projectName',
                          style: TextStyle(color: cs.outline, fontSize: 12)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                        onPressed: () => taskProvider.deleteTask(t.id),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
