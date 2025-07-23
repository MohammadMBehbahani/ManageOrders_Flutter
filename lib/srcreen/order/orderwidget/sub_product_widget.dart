import 'package:flutter/material.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:manageorders/widgets/time_display_widget.dart';

class SubProductExtrasScreen extends StatefulWidget {
  final List<SubProductOption> subProducts;
  final SubProductOption? selectedSubProduct;
  final List<OrderExtra> selectedExtras;
  final List<OrderTopping> selectedToppings;
  final void Function(SubProductOption subProduct) onSubProductSelect;
  final Future<void> Function() onAddExtra;
  final Future<void> Function() onAddTopping;
  final void Function(int index) onRemoveExtra;
  final void Function(int index) onRemoveTopping;

  const SubProductExtrasScreen({
    super.key,
    required this.subProducts,
    required this.selectedSubProduct,
    required this.selectedExtras,
    required this.selectedToppings,
    required this.onSubProductSelect,
    required this.onAddExtra,
    required this.onAddTopping,
    required this.onRemoveExtra,
    required this.onRemoveTopping,
  });

  @override
  State<SubProductExtrasScreen> createState() => _SubProductExtrasScreenState();
}

class _SubProductExtrasScreenState extends State<SubProductExtrasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Product'),
      actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Sub Product:', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.subProducts.map((s) {
                final isSelected = widget.selectedSubProduct?.id == s.id;
                final chipColor = s.color != null ? Color(s.color!) : null;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? chipColor?.withAlpha(204) ??
                                Theme.of(context).colorScheme.primary
                          : chipColor ?? Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 40),
                    ),
                    onPressed: () {
                      widget.onSubProductSelect(s);
                      Navigator.pop(context);
                    },
                    child: Text(
                      s.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 32),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await widget.onAddExtra();
                    setState(() {}); // Force UI to refresh
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Extra'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await widget.onAddTopping();
                    setState(() {}); // Force UI to refresh
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Topping'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.selectedExtras.isNotEmpty) ...[
              const Text('Extras:', style: TextStyle(fontSize: 16)),
              Wrap(
                children: widget.selectedExtras.asMap().entries.map((entry) {
                  final index = entry.key;
                  final extra = entry.value;
                  return Chip(
                    label: Text(
                      '${extra.title} (£${extra.amount.toStringAsFixed(2)})',
                    ),
                    onDeleted: () {
                      widget.onRemoveExtra(index);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            if (widget.selectedToppings.isNotEmpty) ...[
              const Text('Toppings:', style: TextStyle(fontSize: 16)),
              Wrap(
                children: widget.selectedToppings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final topping = entry.value;
                  return Chip(
                    label: Text(
                      '${topping.name} (£${topping.price.toStringAsFixed(2)})',
                    ),
                    onDeleted: () {
                      widget.onRemoveTopping(index);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
