import 'package:flutter/material.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/topping.dart';

class ToppingSelectScreen extends StatefulWidget {
  final List<Topping> availableToppings;

  const ToppingSelectScreen({super.key, required this.availableToppings});

  @override
  State<ToppingSelectScreen> createState() => _ToppingSelectScreenState();
}

class _ToppingSelectScreenState extends State<ToppingSelectScreen> {
  String? selectedToppingId;
  final toppingNameController = TextEditingController();
  final toppingPriceController = TextEditingController();

  void _handleAdd() {
    final price = double.tryParse(toppingPriceController.text) ?? 0.0;

    if (selectedToppingId != null) {
      final existing = widget.availableToppings.firstWhere((t) => t.id == selectedToppingId);
      final result = OrderTopping(
        toppingId: existing.id,
        name: existing.name,
        price: price,
      );
      Navigator.of(context).pop(result);
    } else {
      final name = toppingNameController.text.trim();
      if (name.isNotEmpty) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final result = OrderTopping(
          toppingId: id,
          name: name,
          price: price,
        );
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  void dispose() {
    toppingNameController.dispose();
    toppingPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select or Add Topping')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String?>(
              isExpanded: true,
              hint: const Text('Select Existing Topping'),
              value: selectedToppingId,
              items: widget.availableToppings
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedToppingId = val;
                  if (val != null) toppingNameController.text = '';
                });
              },
            ),
            const Divider(),
            TextField(
              enabled: selectedToppingId == null,
              readOnly: selectedToppingId != null,
              controller: toppingNameController,
              decoration: const InputDecoration(labelText: 'Or Enter New Topping'),
            ),
            TextField(
              controller: toppingPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleAdd,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
