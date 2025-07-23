import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/widgets/time_display_widget.dart';
import 'package:uuid/uuid.dart';

class AddSubProductScreen extends ConsumerStatefulWidget {
  final Product product;
  const AddSubProductScreen({required this.product, super.key});

  @override
  ConsumerState<AddSubProductScreen> createState() =>
      _AddSubProductOptionsScreenState();
}

class _AddSubProductOptionsScreenState
    extends ConsumerState<AddSubProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<SubProductOption> _newOptions = [];
  String _name = '';
  String _price = '';
  int? _color;
  int? _priority;

  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    final products = ref.read(productProvider).value ?? [];
    _currentProduct = products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
  }

  void _pickColor() {
    Color pickerColor = Color(_color ?? Colors.blue.toARGB32());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _color = pickerColor.toARGB32());
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _addOption() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      final newOption = SubProductOption(
        id: const Uuid().v4(),
        name: _name,
        additionalPrice: double.parse(_price),
        color: _color,
        priority: _priority,
      );
      setState(() {
        _newOptions.add(newOption);
        _name = '';
        _price = '';
        _color = null;
        _priority = null;
      });
      _formKey.currentState!.reset();
    }
  }

  Future<void> _deleteOption(SubProductOption option) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete SubProduct Option'),
        content: Text('Are you sure you want to delete "${option.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        if (_currentProduct.availableSubProducts.any((opt) => opt.id == option.id)) {
          _currentProduct = _currentProduct.copyWith(
            availableSubProducts: _currentProduct.availableSubProducts.where((opt) => opt.id != option.id).toList(),
          );
        } else {
          _newOptions.removeWhere((opt) => opt.id == option.id);
        }
      });
    }
  }

  Future<void> _save() async {
    final mergedOptions = [
      ..._currentProduct.availableSubProducts,
      ..._newOptions.where((newOpt) =>
          !_currentProduct.availableSubProducts.any((opt) => opt.id == newOpt.id))
    ];

    final updatedProduct = _currentProduct.copyWith(availableSubProducts: mergedOptions);

    await ref.read(productProvider.notifier).updateProduct(updatedProduct);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final combinedOptions = [
      ..._currentProduct.availableSubProducts,
      ..._newOptions,
    ];

    return Scaffold(
      appBar: AppBar(title: Text('SubProduct Options for "${_currentProduct.name}"'),
      actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _name = val!.trim(),
                      initialValue: _name,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Additional Price'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                      onSaved: (val) => _price = val!,
                      initialValue: _price,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Priority (optional)'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _priority = int.tryParse(val),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Color:'),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _pickColor,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _color != null ? Color(_color!) : Colors.grey,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        if (_color != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text('#${_color!.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
                          )
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _addOption,
                      child: const Text('Add Option'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              if (combinedOptions.isEmpty)
                const Text('No subproduct options available.')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: combinedOptions.length,
                    itemBuilder: (context, index) {
                      final opt = combinedOptions[index];
                      final isNew = _newOptions.any((n) => n.id == opt.id);
                      return Card(
                        color: opt.color != null
                              ? Color(opt.color!)
                              : Colors.white,
                        child: ListTile(
                          title: Text(opt.name),
                          subtitle: Text('Additional Price: £${opt.additionalPrice.toStringAsFixed(2)} • priority: ${opt.priority?? ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteOption(opt),
                          ),
                          tileColor: isNew ? Colors.green.withAlpha((0.1 * 255).round()) : null,
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save All'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
