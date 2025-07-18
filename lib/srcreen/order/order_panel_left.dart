import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:manageorders/providers/manage_left_view_provider.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

class OrderLeftPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(manageLeftViewProvider).value;
    
    final categoryFontSize = (view?.fontsizecategory ?? 22).toDouble();
    final categoryBoxHeight = (view?.boxheightcategory ?? 18).toDouble();
    final categoryBoxWidth = (view?.boxwidthcategory ?? 18).toDouble();
    final productFontSize = (view?.fontsizeproduct ?? 22).toDouble();
    final productBoxHeight = (view?.boxheightproduct ?? 18).toDouble();
    final productBoxWidth = (view?.boxwidthproduct ?? 18).toDouble();

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
                            style:  TextStyle(fontSize: categoryFontSize),
                          ),
                          labelPadding:  EdgeInsets.symmetric(
                            horizontal: categoryBoxWidth,
                            vertical: categoryBoxHeight,
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
            height: maxPadHeight.clamp(minPadHeight, (maxPadHeight * 0.6)),
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
                      label: Text(p.name, style: TextStyle(fontSize: productFontSize)),
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: productBoxWidth,
                        vertical: productBoxHeight,
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
          
        ],
      ),
    );
  }
}
