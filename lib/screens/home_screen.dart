import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/entry_tile.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Time Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear all entries',
            onPressed: () async {
              final entries = context.read<EntryProvider>().entries;
              if (entries.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No entries to clear')),
                );
                return;
              }
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear All Entries'),
                  content: Text(
                      'Delete all ${entries.length} time entries? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<EntryProvider>().clearEntries();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All entries cleared')),
                  );
                }
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.list_rounded),
              text: 'All Entries',
            ),
            Tab(
              icon: Icon(Icons.folder_rounded),
              text: 'By Projects',
            ),
          ],
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.outline,
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AllEntriesTab(),
          _ByProjectsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add-entry'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tab 1: All Entries (flat list)
// ════════════════════════════════════════════════════════════════════════════

class _AllEntriesTab extends StatelessWidget {
  const _AllEntriesTab();

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<EntryProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final entries = entryProvider.entries;

    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.hourglass_empty_rounded,
        message: 'No time entries yet.',
        submessage: 'Tap + to add one.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return EntryTile(
          entry: entry,
          projectName: projectProvider.getTitle(entry.projectId),
          taskName: taskProvider.getTitle(entry.taskId),
          onDelete: () => entryProvider.deleteEntry(entry.id),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tab 2: By Projects (grouped with ExpansionTile)
// ════════════════════════════════════════════════════════════════════════════

class _ByProjectsTab extends StatelessWidget {
  const _ByProjectsTab();

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<EntryProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final grouped = entryProvider.entriesByProject();
    final colorScheme = Theme.of(context).colorScheme;

    if (grouped.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_off_rounded,
        message: 'No entries found.',
        submessage: 'Add time entries to see them grouped by project.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      children: grouped.entries.map((group) {
        final projectTitle = projectProvider.getTitle(group.key);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.folder_rounded,
                  color: colorScheme.onPrimaryContainer, size: 20),
            ),
            title: Text(
              projectTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${group.value.length} ${group.value.length == 1 ? 'entry' : 'entries'}',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            childrenPadding: EdgeInsets.zero,
            children: group.value.map((entry) {
              return EntryTile(
                entry: entry,
                projectName: projectTitle,
                taskName: taskProvider.getTitle(entry.taskId),
                onDelete: () => entryProvider.deleteEntry(entry.id),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
