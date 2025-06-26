import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:manageorders/models/extra.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/providers/category_provider.dart';
import 'package:manageorders/providers/extra_provider.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/order_provider.dart';
import 'package:manageorders/providers/topping_provider.dart';
import 'package:manageorders/srcreen/order/order_panel_left.dart';
import 'package:manageorders/srcreen/order/order_panel_right.dart';
import 'package:manageorders/widgets/print_order.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  String? selectedCategoryId;
  Product? selectedProduct;
  SubProductOption? selectedSubProduct;
  List<OrderExtra> selectedExtras = [];
  List<OrderTopping> selectedToppings = [];
  Discount? selectedDiscount;
  bool isPrintChecked = false;
  // Discount dialog
  void _openDiscountDialog() async {
    String discountType = 'percentage';
    double value = 0.0;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: discountType,
                items: const [
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Percentage'),
                  ),
                  DropdownMenuItem(value: 'flat', child: Text('Flat Amount')),
                ],
                onChanged: (v) => setState(() => discountType = v!),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Value'),
                onChanged: (val) => value = double.tryParse(val) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                setState(() {
                  selectedDiscount = Discount(type: discountType, value: value);
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  // Add Topping dialog
  Future<void> _openToppingDialog() async {
    final toppingList = await ref.watch(toppingProvider.future);
    final availableToppings = toppingList
        .map((t) => OrderTopping(toppingId: t.id, name: t.name, price: 0))
        .toList();

    String? selectedToppingId;
    final toppingNameController = TextEditingController();
    final toppingPriceController = TextEditingController();
    bool addedTopping = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Select or Add Topping'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String?>(
                isExpanded: true,
                hint: const Text('Select Existing Topping'),
                value: selectedToppingId,
                items: availableToppings
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.toppingId,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedToppingId = val),
              ),
              const Divider(),
              TextField(
                enabled: selectedToppingId == null,
                readOnly: selectedToppingId != null,
                controller: toppingNameController,
                decoration: const InputDecoration(
                  labelText: 'Or Enter New Topping',
                ),
              ),
              TextField(
                controller: toppingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final name = toppingNameController.text.trim();
                final price =
                    double.tryParse(toppingPriceController.text) ?? 0.0;

                if (selectedToppingId != null) {
                  final existing = availableToppings.firstWhere(
                    (t) => t.toppingId == selectedToppingId,
                  );
                  setState(() {
                    selectedToppings.add(
                      OrderTopping(
                        toppingId: existing.toppingId,
                        name: existing.name,
                        price: price,
                      ),
                    );
                  });
                  addedTopping = true;
                } else if (name.isNotEmpty) {
                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                  setState(() {
                    selectedToppings.add(
                      OrderTopping(toppingId: id, name: name, price: price),
                    );
                  });
                  addedTopping = true;
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );

    if (addedTopping) {
      setState(() {}); // rebuild outer widget to show updated list
    }
  }

  // Add Extra dialog
  Future<void> _openExtraDialog() async {
    final availableExtras = await ref.watch(extraProvider.future);

    String? selectedExtraId;
    final extraNameController = TextEditingController();
    final extraPriceController = TextEditingController();
    bool addedExtra = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Select or Add Extra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String?>(
                isExpanded: true,
                hint: const Text('Select Existing Extra'),
                value: selectedExtraId,
                items: availableExtras
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.id, child: Text(e.title)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedExtraId = val),
              ),
              const Divider(),
              TextField(
                enabled: selectedExtraId == null,
                readOnly: selectedExtraId != null,
                controller: extraNameController,
                decoration: const InputDecoration(
                  labelText: 'Or Enter New Extra',
                ),
              ),
              TextField(
                controller: extraPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final name = extraNameController.text.trim();
                final price = double.tryParse(extraPriceController.text) ?? 0.0;

                if (selectedExtraId != null) {
                  final existing = availableExtras.firstWhere(
                    (e) => e.id == selectedExtraId,
                  );
                  setState(() {
                    selectedExtras.add(
                      OrderExtra(title: existing.title, amount: price),
                    );
                  });
                  addedExtra = true;
                } else if (name.isNotEmpty) {
                  setState(() {
                    selectedExtras.add(OrderExtra(title: name, amount: price));
                  });
                  addedExtra = true;
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );

    if (addedExtra) {
      setState(() {}); // rebuild to show updated list
    }
  }

  void _addCurrentItemToOrder() {
    final String subProductName;
    final double unitPrice;
    if (selectedProduct == null && selectedSubProduct == null) {
      return;
    } else if (selectedProduct != null &&
        selectedSubProduct == null &&
        selectedProduct!.availableSubProducts.isNotEmpty) {
      return;
    } else if (selectedProduct != null &&
        selectedSubProduct == null &&
        selectedProduct!.availableSubProducts.isEmpty) {
      subProductName = selectedProduct!.name;
      unitPrice = selectedProduct!.basePrice;
    } else {
      subProductName = selectedSubProduct!.name;
      unitPrice =
          selectedProduct!.basePrice + selectedSubProduct!.additionalPrice;
    }

    final item = OrderItem(
      productId: selectedProduct!.id,
      subProductName: subProductName,
      quantity: 1,
      unitPrice: unitPrice,
      extras: [...selectedExtras],
      toppings: [...selectedToppings],
    );

    ref.read(orderProvider.notifier).addItem(item);

    setState(() {
      selectedProduct = null;
      selectedSubProduct = null;
      selectedExtras = [];
      selectedToppings = [];
    });
  }

  Future<void> _submitOrder(String paymentMethod) async {
    final order = await ref
        .read(orderProvider.notifier)
        .submitOrder(paymentMethod: paymentMethod, discount: selectedDiscount);
    setState(() => selectedDiscount = null);
    if (isPrintChecked) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: SizedBox(
            width: 500,
            height: 600,
            child: PrintOrderWidget(order: order),
          ),
        ),
      );
    }
    setState(() {
      isPrintChecked = false;
    });
  }

  void onCategorySelect(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedProduct = null;
      selectedSubProduct = null;
      selectedExtras = [];
      selectedToppings = [];
    });
  }

  void onProductSelect(Product product) {
    setState(() {
      selectedProduct = product;
      selectedSubProduct = null;
      selectedExtras = [];
      selectedToppings = [];
    });
  }

  void onSubProductSelect(SubProductOption subProduct) {
    setState(() => selectedSubProduct = subProduct);
  }

  void onRemoveExtra(int index) {
    setState(() {
      selectedExtras.removeAt(index);
    });
  }

  void onRemoveTopping(int index) {
    setState(() {
      selectedToppings.removeAt(index);
    });
  }

  void onRemoveDiscount() {
    setState(() {
      selectedDiscount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider).valueOrNull ?? [];
    final products = ref.watch(productProvider).valueOrNull ?? [];
    final orderItems = ref.watch(orderProvider);
    final List<Product> filteredProducts = selectedCategoryId == null
        ? []
        : products.where((p) => p.categoryId == selectedCategoryId).toList();

    // Calculate total with discount
    double subtotal = 0.0;
    for (var item in orderItems) {
      double toppingTotal = 0.0;
      if (item.toppings != null) {
        toppingTotal = item.toppings!.fold(0, (sum, t) => sum + t.price);
      }
      double extraTotal = 0.0;
      if (item.extras != null) {
        extraTotal = item.extras!.fold(0, (sum, e) => sum + e.amount);
      }
      subtotal += (item.unitPrice + toppingTotal + extraTotal) * item.quantity;
    }

    double finalTotal = subtotal;
    if (selectedDiscount != null) {
      if (selectedDiscount!.type == 'percentage') {
        finalTotal = subtotal * (1 - selectedDiscount!.value / 100);
      } else if (selectedDiscount!.type == 'flat') {
        finalTotal = (subtotal - selectedDiscount!.value).clamp(
          0,
          double.infinity,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1200;
          if (isWide) {
            return Row(
              children: [
                // LEFT PANEL
                OrderLeftPanel(
                  onAddToOrder: _addCurrentItemToOrder,
                  onAddExtra: _openExtraDialog,
                  onAddTopping: _openToppingDialog,
                  categories: categories,
                  filteredProducts: filteredProducts,
                  selectedCategoryId: selectedCategoryId,
                  selectedProduct: selectedProduct,
                  selectedSubProduct: selectedSubProduct,
                  selectedExtras: selectedExtras,
                  selectedToppings: selectedToppings,
                  onCategorySelect: onCategorySelect,
                  onProductSelect: onProductSelect,
                  onSubProductSelect: onSubProductSelect,
                  onRemoveExtra: onRemoveExtra,
                  onRemoveTopping: onRemoveTopping,
                ),

                // RIGHT PANEL (Order summary)
                OrderRightPanel(
                  orderItems: orderItems,
                  products: products,
                  selectedDiscount: selectedDiscount,
                  finalTotal: finalTotal,
                  isPrintChecked: isPrintChecked,
                  onPrintToggle: (value) =>
                      setState(() => isPrintChecked = value ?? false),
                  onAddDiscount: _openDiscountDialog,
                  onRemoveDiscount: onRemoveDiscount,
                  onSubmitCash: () async => await _submitOrder('cash'),
                  onSubmitCard: () async => _submitOrder('card'),
                  onRemoveItem: (index) =>
                      ref.read(orderProvider.notifier).removeItem(index),
                  onRemoveTopping: (itemIndex, toppingIndex) {
                    final item = orderItems[itemIndex];
                    final newToppings = [...item.toppings!]
                      ..removeAt(toppingIndex);
                    final updated = item.copyWith(toppings: newToppings);
                    final updatedItems = [...orderItems];
                    updatedItems[itemIndex] = updated;
                    ref.read(orderProvider.notifier).updateItems(updatedItems);
                  },
                  onRemoveExtra: (itemIndex, extraIndex) {
                    final item = orderItems[itemIndex];
                    final newExtras = [...item.extras!]..removeAt(extraIndex);
                    final updated = item.copyWith(extras: newExtras);
                    final updatedItems = [...orderItems];
                    updatedItems[itemIndex] = updated;
                    ref.read(orderProvider.notifier).updateItems(updatedItems);
                  },
                ),
              ],
            );
          } else {
            return SizedBox(
              height: constraints.maxHeight, // full screen height
              child: Column(
                children: [
                  OrderLeftPanel(
                    onAddToOrder: _addCurrentItemToOrder,
                    onAddExtra: _openExtraDialog,
                    onAddTopping: _openToppingDialog,
                    categories: categories,
                    filteredProducts: filteredProducts,
                    selectedCategoryId: selectedCategoryId,
                    selectedProduct: selectedProduct,
                    selectedSubProduct: selectedSubProduct,
                    selectedExtras: selectedExtras,
                    selectedToppings: selectedToppings,
                    onCategorySelect: onCategorySelect,
                    onProductSelect: onProductSelect,
                    onSubProductSelect: onSubProductSelect,
                    onRemoveExtra: onRemoveExtra,
                    onRemoveTopping: onRemoveTopping,
                  ),

                  const Divider(thickness: 2),
                  OrderRightPanel(
                    orderItems: orderItems,
                    products: products,
                    selectedDiscount: selectedDiscount,
                    finalTotal: finalTotal,
                    isPrintChecked: isPrintChecked,
                    onPrintToggle: (value) =>
                        setState(() => isPrintChecked = value ?? false),
                    onAddDiscount: _openDiscountDialog,
                    onRemoveDiscount: onRemoveDiscount,
                    onSubmitCash: () async => await _submitOrder('cash'),
                    onSubmitCard: () async => _submitOrder('card'),
                    onRemoveItem: (index) =>
                        ref.read(orderProvider.notifier).removeItem(index),
                    onRemoveTopping: (itemIndex, toppingIndex) {
                      final item = orderItems[itemIndex];
                      final newToppings = [...item.toppings!]
                        ..removeAt(toppingIndex);
                      final updated = item.copyWith(toppings: newToppings);
                      final updatedItems = [...orderItems];
                      updatedItems[itemIndex] = updated;
                      ref
                          .read(orderProvider.notifier)
                          .updateItems(updatedItems);
                    },
                    onRemoveExtra: (itemIndex, extraIndex) {
                      final item = orderItems[itemIndex];
                      final newExtras = [...item.extras!]..removeAt(extraIndex);
                      final updated = item.copyWith(extras: newExtras);
                      final updatedItems = [...orderItems];
                      updatedItems[itemIndex] = updated;
                      ref
                          .read(orderProvider.notifier)
                          .updateItems(updatedItems);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
