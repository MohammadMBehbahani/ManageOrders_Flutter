import 'package:flutter/material.dart';
import 'package:manageorders/models/product.dart';
import 'package:uuid/uuid.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
      text: widget.product?.basePrice.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProduct = widget.product?.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            basePrice: double.tryParse(_priceController.text.trim()) ?? 0,
          ) ??
          Product(
            id: const Uuid().v4(),
            categoryId: '', // Add logic if needed
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            basePrice: double.tryParse(_priceController.text.trim()) ?? 0,
          );
     
      Navigator.of(context).pop(updatedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter product name'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter a price';
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
