import 'package:flutter/material.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/widgets/number_pad.dart';
import 'package:manageorders/widgets/time_display_widget.dart';

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
      appBar: AppBar(title: const Text('Add Discount'),
       actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: discountType,
              items: const [
                DropdownMenuItem(
                  value: 'percentage',
                  child: Text('Percentage'),
                ),
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
            const SizedBox(height: 16),
            NumberPad(
              onKeyTap: (value) {
                setState(() {
                  if (value == 'C') {
                    valueController.clear();
                    this.value = 0.0;
                  } else if (value == '⌫') {
                    final current = valueController.text;
                    if (current.isNotEmpty) {
                      valueController.text = current.substring(
                        0,
                        current.length - 1,
                      );
                      this.value = double.tryParse(valueController.text) ?? 0.0;
                    }
                  } else {
                    final current = valueController.text;
                    if (value == '.' && current.contains('.')) return;
                    valueController.text = current + value;
                    this.value = double.tryParse(valueController.text) ?? 0.0;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
