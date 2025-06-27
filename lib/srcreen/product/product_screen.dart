import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/category_provider.dart';
import 'package:manageorders/srcreen/product/add_update_product_screen.dart';
import 'package:manageorders/srcreen/product/product_extra_screen.dart';
import 'package:manageorders/srcreen/product/product_topping_screen.dart';
import 'package:manageorders/srcreen/product/sub_product_screen.dart';
import 'package:uuid/uuid.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  // To track product being edited (null means adding)
  Product? editingProduct;

  void _openProductScreen([Product? product]) async{
    setState(() {
      editingProduct = product;
    });

    final savedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(
          product: product,
        ),
      ),
    );

   if (savedProduct != null) {
    final notifier = ref.read(productProvider.notifier);
    if (product == null) {
      // Add new
      await notifier.addProduct(
        savedProduct.copyWith(id: const Uuid().v4()),
      );
    } else {
      // Update existing
      await notifier.updateProduct(savedProduct);
    }
  }
  }


  void _confirmDelete(String productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(productProvider.notifier).deleteProduct(productId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryProvider);
    final asyncProducts = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: asyncCategories.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading categories: $e')),
          data: (categories) {
            final categoryOptions = [
              Category(id: 'all', name: 'All Categories'),
              ...categories,
            ];

            return asyncProducts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading products: $e')),
              data: (products) {
                // Filter by category
                var filteredProducts = selectedCategoryId == 'all'
                    ? products
                    : products
                          .where((p) => p.categoryId == selectedCategoryId)
                          .toList();

                // Filter by search query
                if (searchQuery.isNotEmpty) {
                  filteredProducts = filteredProducts
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search + Filter + Add Product Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Search products',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (val) {
                              setState(() {
                                searchQuery = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButton<String>(
                            value: selectedCategoryId,
                            isExpanded: true,
                            items: categoryOptions
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedCategoryId = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                          onPressed: () => _openProductScreen(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Products List
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(child: Text('No products found.'))
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final p = filteredProducts[index];
                                final categoryName = categories
                                    .firstWhere(
                                      (c) => c.id == p.categoryId,
                                      orElse: () =>
                                          Category(id: '', name: 'Unknown'),
                                    )
                                    .name;

                                return Card(
                                  child: ListTile(
                                    title: Text(p.name),
                                    subtitle: Text(
                                      '£${p.basePrice.toStringAsFixed(2)} • $categoryName',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          tooltip: 'Edit product',
                                          onPressed: () => _openProductScreen(p),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          tooltip: 'Delete product',
                                          color: Colors.red,
                                          onPressed: () => _confirmDelete(p.id),
                                        ),

                                        // Add Extra
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_box_outlined,
                                          ),
                                          tooltip: 'Add Extra',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddProductExtrasScreen(
                                                      product: p,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Add Topping
                                        IconButton(
                                          icon: const Icon(
                                            Icons.local_pizza_outlined,
                                          ),
                                          tooltip: 'Add Topping',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddProductToppingsScreen(
                                                      product: p,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Add SubProductOption
                                        IconButton(
                                          icon: const Icon(
                                            Icons.layers_outlined,
                                          ),
                                          tooltip: 'Add SubProduct Option',
                                          onPressed: () => {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddSubProductScreen(
                                                      product: p,
                                                    ),
                                              ),
                                            ),
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Separate Widget for the Add/Edit Product Modal form
class ProductFormModal extends ConsumerStatefulWidget {
  final Product? product;
  final void Function(Product product) onSave;

  const ProductFormModal({super.key, this.product, required this.onSave});

  @override
  ConsumerState<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends ConsumerState<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();

  String? _id;
  String? _categoryId;
  String _name = '';
  String _description = '';
  double _basePrice = 0.0;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _id = p.id;
      _categoryId = p.categoryId;
      _name = p.name;
      _description = p.description ?? '';
      _basePrice = p.basePrice;
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      widget.onSave(
        Product(
          id: _id ?? '',
          categoryId: _categoryId ?? '',
          name: _name,
          description: _description,
          basePrice: _basePrice,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.read(categoryProvider).value ?? [];

    return AlertDialog(
      title: Text(_id == null ? 'Add Product' : 'Edit Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please select category'
                      : null,
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _categoryId = val),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Name is required' : null,
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (val) => _description = val ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _basePrice != 0.0 ? _basePrice.toString() : '',
                  decoration: const InputDecoration(labelText: 'Base Price'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Base price required';
                    }
                    if (double.tryParse(val) == null) return 'Invalid number';
                    return null;
                  },
                  onSaved: (val) => _basePrice = double.parse(val!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
