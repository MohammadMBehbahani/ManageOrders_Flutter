import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';

class OrderLeftPanel extends StatelessWidget {
  final List<Category> categories;
  final List<Product> filteredProducts;
  final String? selectedCategoryId;
  final Product? selectedProduct;
  final SubProductOption? selectedSubProduct;
  final List<OrderExtra> selectedExtras;
  final List<OrderTopping> selectedToppings;
  final void Function(String categoryId) onCategorySelect;
  final void Function(Product product) onProductSelect;
  final void Function(SubProductOption subProduct) onSubProductSelect;
  final void Function(int index) onRemoveExtra;
  final void Function(int index) onRemoveTopping;
  final VoidCallback onAddExtra;
  final VoidCallback onAddTopping;
  final VoidCallback onAddToOrder;

  const OrderLeftPanel({
    super.key,
    required this.categories,
    required this.filteredProducts,
    required this.selectedCategoryId,
    required this.selectedProduct,
    required this.selectedSubProduct,
    required this.selectedExtras,
    required this.selectedToppings,
    required this.onCategorySelect,
    required this.onProductSelect,
    required this.onSubProductSelect,
    required this.onRemoveExtra,
    required this.onRemoveTopping,
    required this.onAddExtra,
    required this.onAddTopping,
    required this.onAddToOrder,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (c) => ChoiceChip(
                      label: Text(c.name, style: const TextStyle(fontSize: 18)),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      selected: selectedCategoryId == c.id,
                      onSelected: (_) => onCategorySelect(c.id),
                    ),
                  )
                  .toList(),
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredProducts.map((p) {
                final isSelected = selectedProduct?.id == p.id;
                return ChoiceChip(
                  label: Text(p.name, style: const TextStyle(fontSize: 18)),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  selected: isSelected,
                  onSelected: (_) => onProductSelect(p),
                );
              }).toList(),
            ),
            const Divider(),
            if (selectedProduct != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedProduct!.availableSubProducts
                    .map(
                      (s) => ChoiceChip(
                        label: Text(
                          s.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        selected: selectedSubProduct?.id == s.id,
                        onSelected: (_) => onSubProductSelect(s),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedExtras.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Selected Extras:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ListView.builder(
                          itemCount: selectedExtras.length,
                          itemBuilder: (context, index) {
                            final extra = selectedExtras[index];
                            return ListTile(
                              title: Text(extra.title),
                              subtitle: Text(
                                '£${extra.amount.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => onRemoveExtra(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (selectedToppings.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Selected Toppings:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ListView.builder(
                          itemCount: selectedToppings.length,
                          itemBuilder: (context, index) {
                            final topping = selectedToppings[index];
                            return ListTile(
                              title: Text(topping.name),
                              subtitle: Text(
                                '£${topping.price.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => onRemoveTopping(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if ((width < 1200 && height < 700) || height <= 350 || (width < 450 && height < 1000))
                Row(
                  children: [
                    const SizedBox(height: 2),
                    ActionChip(
                      label: const Text('+ Add Extra'),
                      onPressed: onAddExtra,
                    ),
                    const SizedBox(width: 2),
                    ActionChip(
                      label: const Text('+ Add Topping'),
                      onPressed: onAddTopping,
                    ),
                    const SizedBox(width: 2),
                    ElevatedButton(
                      onPressed: onAddToOrder,
                      child: const Text(
                        'Add Order',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const SizedBox(height: 8),
                    ActionChip(
                      label: const Text('+ Add Extra'),
                      onPressed: onAddExtra,
                    ),
                    const SizedBox(height: 8),
                    ActionChip(
                      label: const Text('+ Add Topping'),
                      onPressed: onAddTopping,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: onAddToOrder,
                      child: const Text(
                        'Add to Order',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
