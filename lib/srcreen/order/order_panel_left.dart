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

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.22)),
                width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
                child: ScrollWithTouch(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
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
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              const Divider(),
              SizedBox(
                height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.2)),
                width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
                child: ScrollWithTouch(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredProducts.map((p) {
                        final isSelected = selectedProduct?.id == p.id;
                        return ChoiceChip(
                          label: Text(
                            p.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          selected: isSelected,
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
                  height: maxPadHeight.clamp(
                    minPadHeight,
                    (maxPadHeight * 0.1),
                  ),
                  width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
                  child: ScrollWithTouch(
                    child: SingleChildScrollView(
                      child: Wrap(
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
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: maxPadHeight.clamp(
                    minPadHeight,
                    (maxPadHeight * 0.1),
                  ),
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
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
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
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
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
