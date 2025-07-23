import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/topping_provider.dart';
import 'package:manageorders/widgets/time_display_widget.dart';

class AddProductToppingsScreen extends ConsumerStatefulWidget {
  final Product product;
  const AddProductToppingsScreen({required this.product, super.key});

  @override
  ConsumerState<AddProductToppingsScreen> createState() =>
      _AddProductToppingsScreenState();
}

class _AddProductToppingsScreenState
    extends ConsumerState<AddProductToppingsScreen> {
  late Set<String> _selectedToppingIds;

  @override
  void initState() {
    super.initState();
    _selectedToppingIds = widget.product.availableToppings.map((e) => e.id).toSet();
  }

  void _toggleSelection(String toppingId) {
    setState(() {
      if (_selectedToppingIds.contains(toppingId)) {
        _selectedToppingIds.remove(toppingId);
      } else {
        _selectedToppingIds.add(toppingId);
      }
    });
  }

  Future<void> _save() async {
    final allToppings = ref.read(toppingProvider).value ?? [];
    final selectedToppings = allToppings
        .where((topping) => _selectedToppingIds.contains(topping.id))
        .toList();

    final updatedProduct = widget.product.copyWith(availableToppings: selectedToppings);
    await ref.read(productProvider.notifier).updateProduct(updatedProduct);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final toppingsAsync = ref.watch(toppingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Toppings'),
      actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ]),
      body: toppingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No Data')),
        data: (toppings) {
          if (toppings.isEmpty) {
            return const Center(child: Text('No toppings available.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: toppings.map((topping) {
                    final isSelected = _selectedToppingIds.contains(topping.id);
                    return CheckboxListTile(
                      title: Text(topping.name),
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(topping.id),
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
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
