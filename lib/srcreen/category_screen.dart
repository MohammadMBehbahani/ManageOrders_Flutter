import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/providers/category_provider.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priorityController = TextEditingController();
  String? _editingCategoryId;
  int? _selectedColor;

  void _pickColor(BuildContext context) {
    Color pickerColor = Color(_selectedColor ?? Colors.blue.toARGB32());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                setStateDialog(() => pickerColor = color);
              },
              enableAlpha: false,
              labelTypes: const [ColorLabelType.hex],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Select'),
            onPressed: () {
              setState(() => _selectedColor = pickerColor.toARGB32());
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final priorityText = _priorityController.text.trim();
      final color = _selectedColor;
      final priority = int.tryParse(priorityText);

      if (_editingCategoryId == null) {
        await ref
            .read(categoryProvider.notifier)
            .addCategory(name, priority: priority, color: color);
      } else {
        await ref
            .read(categoryProvider.notifier)
            .updateCategory(
              _editingCategoryId!,
              name,
              priority: priority,
              color: color,
            );
      }

      _nameController.clear();
      _priorityController.clear();
      _editingCategoryId = null;
      setState(() => _selectedColor = null);
    }
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategoryId = category.id;
      _nameController.text = category.name;
      _priorityController.text = category.priority?.toString() ?? '';
      _selectedColor = category.color;
    });
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

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Wrap(
                runSpacing: 12,
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Enter name'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _priorityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: GestureDetector(
                      onTap: () => _pickColor(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor != null
                              ? Color(_selectedColor!)
                              : Colors.grey,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_editingCategoryId == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: asyncCategories.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories found.'));
                  }

                  final sorted = [...categories]
                    ..sort((a, b) {
                      if (a.priority == null && b.priority == null) return 0;
                      if (a.priority == null) return 1;
                      if (b.priority == null) return -1;
                      return a.priority!.compareTo(b.priority!);
                    });

                  return ScrollWithTouch(
                    child: ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (_, i) {
                        final cat = sorted[i];
                        return Card(
                          color: cat.color != null
                              ? Color(cat.color!)
                              : Colors.white,
                          child: ListTile(
                            title: Text(cat.name),
                            subtitle: cat.priority != null
                                ? Text('Priority: ${cat.priority}')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editCategory(cat),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteCategory(cat.id),
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
