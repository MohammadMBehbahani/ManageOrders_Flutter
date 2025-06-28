import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/topping.dart';
import 'package:manageorders/providers/topping_provider.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

class ToppingScreen extends ConsumerStatefulWidget {
  const ToppingScreen({super.key});

  @override
  ConsumerState<ToppingScreen> createState() => _ToppingScreenState();
}

class _ToppingScreenState extends ConsumerState<ToppingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _editingtoppingId;

  Future _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      if (_editingtoppingId == null) {
        await ref.read(toppingProvider.notifier).addTopping(name);
      } else {
        await ref
            .read(toppingProvider.notifier)
            .updateTopping(_editingtoppingId!, name);
      }

      _nameController.clear();
      _editingtoppingId = null;
    }
  }

  void _deletetopping(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete topping'),
        content: const Text('Are you sure you want to delete this topping?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(toppingProvider.notifier).deleteTopping(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _edittopping(Topping topping) {
    setState(() {
      _editingtoppingId = topping.id;
      _nameController.text = topping.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncTopping = ref.watch(toppingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Topping')),
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
                        labelText: 'topping Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter a topping name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_editingtoppingId == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// topping LIST
            Expanded(
              child: asyncTopping.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('no data')),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(child: Text('No Topping found.'));
                  }

                  return ScrollWithTouch(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        return Card(
                          child: ListTile(
                            title: Text(cat.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _edittopping(cat),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletetopping(cat.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
