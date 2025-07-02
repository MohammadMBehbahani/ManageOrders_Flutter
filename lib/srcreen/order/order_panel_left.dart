import 'package:flutter/material.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

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
    final screenHeight = MediaQuery.of(context).size;
    final maxPadHeight = screenHeight.height;
    final minPadHeight =
        screenHeight.height - ((screenHeight.height * 98) / 100);

    final maxPadwidth = screenHeight.width;
    final minPadwidth = screenHeight.width - ((screenHeight.width * 98) / 100);

    final sortedCategories = [...categories]
      ..sort((a, b) {
        if (a.priority == null && b.priority == null) return 0;
        if (a.priority == null) return 1;
        if (b.priority == null) return -1;
        return a.priority!.compareTo(b.priority!);
      });

    final sortedProducts = [...filteredProducts]
      ..sort((a, b) {
        if (a.priority == null && b.priority == null) return 0;
        if (a.priority == null) return 1;
        if (b.priority == null) return -1;
        return a.priority!.compareTo(b.priority!);
      });

    List<SubProductOption> sortedSubProducts = [];
    if (selectedProduct != null) {
      sortedSubProducts = [...selectedProduct!.availableSubProducts]
        ..sort((a, b) {
          if (a.priority == null && b.priority == null) return 0;
          if (a.priority == null) return 1;
          if (b.priority == null) return -1;
          return a.priority!.compareTo(b.priority!);
        });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.20)),
            width: maxPadwidth,
            child: ScrollWithTouch(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sortedCategories
                      .map(
                        (c) => ChoiceChip(
                          label: Text(
                            c.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          selected: selectedCategoryId == c.id,
                          onSelected: (_) => onCategorySelect(c.id),
                          backgroundColor: c.color != null
                              ? Color(c.color!)
                              : null,
                          selectedColor: c.color != null
                              ? Color(c.color!).withAlpha(
                                  204,
                                ) // 204 = 0.8 * 255 (opacity)
                              : Theme.of(context).colorScheme.primary.withAlpha(
                                  77,
                                ), // fallback: 0.3 * 255
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const Divider(),
          SizedBox(
            height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.40)),
            width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
            child: ScrollWithTouch(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sortedProducts.map((p) {
                    final isSelected = selectedProduct?.id == p.id;
                    final chipColor = p.color != null ? Color(p.color!) : null;

                    return ChoiceChip(
                      label: Text(p.name, style: const TextStyle(fontSize: 18)),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      selected: isSelected,
                      selectedColor: chipColor?..withAlpha(204),
                      backgroundColor: chipColor,
                      onSelected: (_) => onProductSelect(p),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const Divider(),
          if (selectedProduct != null) ...[
            SizedBox(
              height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.1)),
              width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
              child: ScrollWithTouch(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortedSubProducts.map((s) {
                      final isSelected = selectedSubProduct?.id == s.id;
                      final chipColor = s.color != null
                          ? Color(s.color!)
                          : null;

                      return ChoiceChip(
                        label: Text(
                          s.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        selected: isSelected,
                        backgroundColor: chipColor,
                        selectedColor: chipColor?..withAlpha(
                                  204,
                                ),
                        onSelected: (_) => onSubProductSelect(s),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.1)),
              width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
              child: ScrollWithTouch(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Buttons group
                      Row(
                        children: [
                          ActionChip(
                            label: const Text('+ Add Extra'),
                            onPressed: onAddExtra,
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            label: const Text('+ Add Topping'),
                            onPressed: onAddTopping,
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Selected Extras
                      if (selectedExtras.isNotEmpty) ...[
                        const Text(
                          'Extras:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: maxPadHeight.clamp(
                            minPadHeight,
                            (maxPadHeight * 0.1),
                          ),
                          width: maxPadwidth.clamp(
                            minPadwidth,
                            (maxPadwidth * 0.3),
                          ),
                          child: ScrollWithTouch(
                            child: SingleChildScrollView(
                              child: Column(
                                children: selectedExtras.map((extra) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Chip(
                                      label: Text(
                                        '${extra.title} (£${extra.amount.toStringAsFixed(2)})',
                                      ),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () => onRemoveExtra(
                                        selectedExtras.indexOf(extra),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(width: 16),

                      // Selected Toppings
                      if (selectedToppings.isNotEmpty) ...[
                        const Text(
                          'Toppings:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: maxPadHeight.clamp(
                            minPadHeight,
                            (maxPadHeight * 0.1),
                          ),
                          width: maxPadwidth.clamp(
                            minPadwidth,
                            (maxPadwidth * 0.3),
                          ),
                          child: ScrollWithTouch(
                            child: SingleChildScrollView(
                              child: Column(
                                children: selectedToppings.map((topping) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Chip(
                                      label: Text(
                                        '${topping.name} (£${topping.price.toStringAsFixed(2)})',
                                      ),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () => onRemoveTopping(
                                        selectedToppings.indexOf(topping),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
