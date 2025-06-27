import 'package:flutter/material.dart';
import 'package:manageorders/models/discount.dart';

class DiscountSelectScreen extends StatefulWidget {
  const DiscountSelectScreen({super.key});

  @override
  State<DiscountSelectScreen> createState() => _DiscountSelectScreenState();
}

class _DiscountSelectScreenState extends State<DiscountSelectScreen> {
  String discountType = 'percentage';
  double value = 0.0;
  final valueController = TextEditingController();

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  void _applyDiscount() {
    final discount = Discount(type: discountType, value: value);
    Navigator.of(context).pop(discount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Discount')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: discountType,
              items: const [
                DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                DropdownMenuItem(value: 'flat', child: Text('Flat Amount')),
              ],
              onChanged: (v) => setState(() => discountType = v!),
            ),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value'),
              onChanged: (val) => value = double.tryParse(val) ?? 0.0,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyDiscount,
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
