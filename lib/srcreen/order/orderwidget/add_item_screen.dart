import 'package:flutter/material.dart';
import 'package:manageorders/widgets/full_keyboard_widget.dart';

class AddOrderItemProductScreen extends StatefulWidget {
  const AddOrderItemProductScreen({super.key});

  @override
  State<AddOrderItemProductScreen> createState() =>
      _AddOrderItemProductScreenState();
}

class _AddOrderItemProductScreenState extends State<AddOrderItemProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  final FocusNode focusNodename = FocusNode();
  final FocusNode focusNodeprice = FocusNode();

  late TextEditingController activeController;

  @override
  void initState() {
    super.initState();

    activeController = priceController;

    focusNodename.addListener(() {
      if (focusNodename.hasFocus) {
        setState(() => activeController = nameController);
      }
    });

    focusNodeprice.addListener(() {
      if (focusNodeprice.hasFocus) {
        setState(() => activeController = priceController);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    focusNodename.dispose();
    focusNodeprice.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (price <= 0) {
      return;
    }

    Navigator.of(context).pop({'name': name, 'price': price});
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
              focusNode: focusNodename,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: priceController,
              focusNode: focusNodeprice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save', style: TextStyle(fontSize: 30),)),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: FullKeyboard(
                  controller: activeController,
                  onKeyTap: (text) {
                    activeController.text = text;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
