import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/extra_provider.dart';

class AddProductExtrasScreen extends ConsumerStatefulWidget {
  final Product product;
  const AddProductExtrasScreen({required this.product, super.key});

  @override
  ConsumerState<AddProductExtrasScreen> createState() => _AddProductExtrasState();
}

class _AddProductExtrasState extends ConsumerState<AddProductExtrasScreen> {
  late Set<String> _selectedExtraIds;

  @override
  void initState() {
    super.initState();
    _selectedExtraIds = widget.product.availableExtras.map((e) => e.id).toSet();
  }

  void _toggleSelection(String extraId) {
    setState(() {
      if (_selectedExtraIds.contains(extraId)) {
        _selectedExtraIds.remove(extraId);
      } else {
        _selectedExtraIds.add(extraId);
      }
    });
  }

  void _save() async {
    final allExtras = ref.read(extraProvider).value ?? [];
    final selectedExtras = allExtras
        .where((extra) => _selectedExtraIds.contains(extra.id))
        .toList();

    final updatedProduct = widget.product.copyWith(availableExtras: selectedExtras);
    await ref.read(productProvider.notifier).updateProduct(updatedProduct);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final extrasAsync = ref.watch(extraProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Extras')),
      body: extrasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No Data')),
        data: (extras) {
          if (extras.isEmpty) {
            return const Center(child: Text('No extras available.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: extras.map((extra) {
                    final isSelected = _selectedExtraIds.contains(extra.id);
                    return CheckboxListTile(
                      title: Text(extra.title),
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(extra.id),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
              const SizedBox(height: 50)
            ],
          );
        },
      ),
    );
  }
}
