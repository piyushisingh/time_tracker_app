import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/empty_state.dart';

class LocalStorageScreen extends StatefulWidget {
  const LocalStorageScreen({super.key});

  @override
  State<LocalStorageScreen> createState() => _LocalStorageScreenState();
}

class _LocalStorageScreenState extends State<LocalStorageScreen> {
  final StorageService _storage = StorageService();
  Map<String, String?> _rawData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _storage.loadRawData();
    setState(() {
      _rawData = data;
      _isLoading = false;
    });
  }

  String _formatJson(String? raw) {
    if (raw == null || raw.isEmpty) return 'null';
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw;
    }
  }

  bool get _isEmpty => _rawData.values.every((v) => v == null || v == '[]');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEmpty
              ? const EmptyState(
                  icon: Icons.storage_rounded,
                  message: 'Local storage is empty.',
                  submessage: 'Add some data to see it here.',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _rawData.entries.map((e) {
                    final formatted = _formatJson(e.value);
                    final count = e.value != null
                        ? (jsonDecode(e.value!) as List).length
                        : 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: ExpansionTile(
                        leading: Icon(Icons.data_object_rounded, color: cs.tertiary),
                        title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('$count items', style: TextStyle(color: cs.outline, fontSize: 12)),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              formatted,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
