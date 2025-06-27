
import 'package:flutter/material.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/extra.dart';

class ExtraSelectScreen extends StatefulWidget {
  final List<Extra> availableExtras;

  const ExtraSelectScreen({super.key, required this.availableExtras});

  @override
  State<ExtraSelectScreen> createState() => _ExtraSelectScreenState();
}

class _ExtraSelectScreenState extends State<ExtraSelectScreen> {
  String? selectedExtraId;
  final extraNameController = TextEditingController();
  final extraPriceController = TextEditingController();

  void _handleAdd() {
    final price = double.tryParse(extraPriceController.text) ?? 0.0;

    if (selectedExtraId != null) {
      final existing = widget.availableExtras.firstWhere((e) => e.id == selectedExtraId);
      final result = OrderExtra(title: existing.title, amount: price);
      Navigator.of(context).pop(result);
    } else {
      final name = extraNameController.text.trim();
      if (name.isNotEmpty) {
        final result = OrderExtra(title: name, amount: price);
        Navigator.of(context).pop(result);
      }
    }
  }

  @override
  void dispose() {
    extraNameController.dispose();
    extraPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select or Add Extra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String?>(
              isExpanded: true,
              hint: const Text('Select Existing Extra'),
              value: selectedExtraId,
              items: widget.availableExtras
                  .map(
                    (e) => DropdownMenuItem(value: e.id, child: Text(e.title)),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedExtraId = val;
                  if (val != null) {
                    extraNameController.text = ''; // Clear name input if selecting existing
                  }
                });
              },
            ),
            const Divider(),
            TextField(
              enabled: selectedExtraId == null,
              readOnly: selectedExtraId != null,
              controller: extraNameController,
              decoration: const InputDecoration(labelText: 'Or Enter New Extra'),
            ),
            TextField(
              controller: extraPriceController,
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
