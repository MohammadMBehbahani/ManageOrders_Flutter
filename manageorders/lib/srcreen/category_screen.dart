import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/providers/category_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _editingCategoryId;

  Future _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      if (_editingCategoryId == null) {
        await ref.read(categoryProvider.notifier).addCategory(name);
      } else {
        await ref
            .read(categoryProvider.notifier)
            .updateCategory(_editingCategoryId!, name);
      }

      _nameController.clear();
      _editingCategoryId = null;
    }
  }

  void _deleteCategory(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(categoryProvider.notifier).deleteCategory(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategoryId = category.id;
      _nameController.text = category.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
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
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter a category name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_editingCategoryId == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// CATEGORY LIST
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
                          title: Text(cat.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editCategory(cat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(cat.id),
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
