import 'package:flutter/material.dart';

class AddOrderItemProductScreen extends StatefulWidget {
 

  const AddOrderItemProductScreen({
    super.key
  });

  @override
  State<AddOrderItemProductScreen> createState() => _AddOrderItemProductScreenState();
}

class _AddOrderItemProductScreenState extends State<AddOrderItemProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();


  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    Navigator.of(context).pop({
      'name': name,
      'price': price,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
