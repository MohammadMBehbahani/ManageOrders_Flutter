import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/extra.dart';
import 'package:manageorders/providers/extra_provider.dart';
import 'package:manageorders/srcreen/shared/layout_screen.dart';

class ExtraScreen extends ConsumerStatefulWidget {
  const ExtraScreen({super.key});

  @override
  ConsumerState<ExtraScreen> createState() => _ExtraScreenState();
}

class _ExtraScreenState extends ConsumerState<ExtraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _editingExtraId;

  Future _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      if (_editingExtraId == null) {
        await ref.read(extraProvider.notifier).addExtra(name);
      } else {
        await ref
            .read(extraProvider.notifier)
            .updateExtra(_editingExtraId!, name);
      }

      _nameController.clear();
      _editingExtraId = null;
    }
  }

  void _deleteExtra(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Extra'),
        content: const Text('Are you sure you want to delete this Extra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(extraProvider.notifier).deleteExtra(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editExtra(Extra extra) {
    setState(() {
      _editingExtraId = extra.id;
      _nameController.text = extra.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(extraProvider);

    return LayoutScreen(
      title: 'Extra',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// FORM
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Extra Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter a Extra name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_editingExtraId == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// Extra LIST
            Expanded(
              child: asyncCategories.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories found.'));
                  }

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      return Card(
                        child: ListTile(
                          title: Text(cat.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editExtra(cat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExtra(cat.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
