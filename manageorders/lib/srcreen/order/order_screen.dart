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
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/order_provider.dart';
import 'package:manageorders/srcreen/shared/layout_screen.dart';
import 'package:flutter/gestures.dart';
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
    final products = ref.read(productProvider).valueOrNull ?? [];
    // collect all unique toppings from all products
    final Map<String, OrderTopping> availableToppingsMap = {};
    for (var p in products) {
      for (var t in p.availableToppings) {
        availableToppingsMap[t.id] = OrderTopping(
          toppingId: t.id,
          name: t.name,
          price: 0,
        );
      }
    }
    final availableToppings = availableToppingsMap.values.toList();

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
    final products = ref.read(productProvider).valueOrNull ?? [];
    // collect all unique extras from all products
    final Map<String, Extra> availableExtrasMap = {};
    for (var p in products) {
      for (var e in p.availableExtras) {
        availableExtrasMap[e.id] = e;
      }
    }
    final availableExtras = availableExtrasMap.values.toList();

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
      setState(() {}); // rebuild outer widget to show updated list
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

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider).valueOrNull ?? [];
    final products = ref.watch(productProvider).valueOrNull ?? [];
    final orderItems = ref.watch(orderProvider);
    final filteredProducts = selectedCategoryId == null
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

    return LayoutScreen(
      title: 'Create Order',
      body: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            // LEFT PANEL
            Expanded(
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
                              label: Text(c.name),
                              selected: selectedCategoryId == c.id,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategoryId = c.id;
                                  selectedProduct = null;
                                  selectedSubProduct = null;
                                  selectedExtras = [];
                                  selectedToppings = [];
                                });
                              },
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
                          label: Text(p.name),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedProduct = p;
                              selectedSubProduct = null;
                              selectedExtras = [];
                              selectedToppings = [];
                            });
                          },
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
                                label: Text(s.name),
                                selected: selectedSubProduct?.id == s.id,
                                onSelected: (_) =>
                                    setState(() => selectedSubProduct = s),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(
                        height: 12,
                      ), // ⬅️ Needed for PointerDeviceKind

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
                              height: 120,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(
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
                                        onPressed: () {
                                          setState(() {
                                            selectedExtras.removeAt(index);
                                          });
                                        },
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
                              height: 120,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(
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
                                        onPressed: () {
                                          setState(() {
                                            selectedToppings.removeAt(index);
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          ActionChip(
                            label: const Text('+ Add Extra'),
                            onPressed: _openExtraDialog,
                          ),
                          const SizedBox(height: 8),
                          ActionChip(
                            label: const Text('+ Add Topping'),
                            onPressed: _openToppingDialog,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addCurrentItemToOrder,
                        child: const Text('Add to Order'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // RIGHT PANEL (Order summary)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: orderItems.length,
                        itemBuilder: (_, i) {
                          final item = orderItems[i];
                          return Card(
                            child: ExpansionTile(
                              title: Text(
                                '${products.firstWhere((p) => p.id == item.productId).name} - ${item.subProductName} x${item.quantity}',
                              ),
                              subtitle: Text(
                                '£${item.totalPrice.toStringAsFixed(2)}',
                              ),
                              children: [
                                if (item.toppings != null &&
                                    item.toppings!.isNotEmpty)
                                  ...item.toppings!.map(
                                    (t) => ListTile(
                                      title: Text(
                                        'Topping: ${t.name} (£${t.price.toStringAsFixed(2)})',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          final newToppings = [
                                            ...item.toppings!,
                                          ]..remove(t);
                                          final updated = item.copyWith(
                                            toppings: newToppings,
                                          );
                                          final updatedItems = [...orderItems];
                                          updatedItems[i] = updated;
                                          ref
                                              .read(orderProvider.notifier)
                                              .updateItems(updatedItems);
                                        },
                                      ),
                                    ),
                                  ),
                                if (item.extras != null &&
                                    item.extras!.isNotEmpty)
                                  ...item.extras!.map(
                                    (e) => ListTile(
                                      title: Text(
                                        'Extra: ${e.title} (£${e.amount.toStringAsFixed(2)})',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          final newExtras = [...item.extras!]
                                            ..remove(e);
                                          final updated = item.copyWith(
                                            extras: newExtras,
                                          );
                                          final updatedItems = [...orderItems];
                                          updatedItems[i] = updated;
                                          ref
                                              .read(orderProvider.notifier)
                                              .updateItems(updatedItems);
                                        },
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => ref
                                      .read(orderProvider.notifier)
                                      .removeItem(i),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    if (selectedDiscount != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Discount Applied: ${selectedDiscount!.type} ${selectedDiscount!.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDiscount = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Total: £${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: isPrintChecked,
                          onChanged: (value) {
                            setState(() {
                              isPrintChecked = value ?? false;
                            });
                          },
                        ),
                        const Text('Print'),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.percent),
                          label: const Text('Add Discount'),
                          onPressed: _openDiscountDialog,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text('Submit Cash'),
                          onPressed: () async {
                            await _submitOrder('cash');
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text('Submit Card'),
                          onPressed: () async {
                            await _submitOrder('card');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
