import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:manageorders/models/discount.dart';

class OrderRightPanel extends StatelessWidget {
  final List<OrderItem> orderItems;
  final Discount? selectedDiscount;
  final double finalTotal;
  final bool isPrintChecked;
  final ValueChanged<bool?> onPrintToggle;
  final VoidCallback onAddDiscount;
  final VoidCallback onRemoveDiscount;
  final VoidCallback onSubmitCash;
  final VoidCallback onSubmitCard;
  final VoidCallback onAddItem;
  
  final void Function(int itemIndex) onRemoveItem;
  final void Function(int itemIndex, int toppingIndex) onRemoveTopping;
  final void Function(int itemIndex, int extraIndex) onRemoveExtra;

  const OrderRightPanel({
    super.key,
    required this.orderItems,
    required this.selectedDiscount,
    required this.finalTotal,
    required this.isPrintChecked,
    required this.onPrintToggle,
    required this.onAddDiscount,
    required this.onRemoveDiscount,
    required this.onSubmitCash,
    required this.onSubmitCard,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onRemoveTopping,
    required this.onRemoveExtra,
  });

  @override
  Widget build(BuildContext context) {

    return  Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (_, i) {
                    final item = orderItems[i];
                    return Card(
                      child: ExpansionTile(
                        title: Text(
                          '${item.product.name} - ${item.subProductName} x${item.quantity}',
                        ),
                        subtitle: Text(
                          '£${item.totalPrice.toStringAsFixed(2)}',
                        ),
                        children: [
                          if (item.toppings != null &&
                              item.toppings!.isNotEmpty)
                            ...List.generate(item.toppings!.length, (tIndex) {
                              final t = item.toppings![tIndex];
                              return ListTile(
                                title: Text(
                                  'Topping: ${t.name} (£${t.price.toStringAsFixed(2)})',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => onRemoveTopping(i, tIndex),
                                ),
                              );
                            }),
                          if (item.extras != null && item.extras!.isNotEmpty)
                            ...List.generate(item.extras!.length, (eIndex) {
                              final e = item.extras![eIndex];
                              return ListTile(
                                title: Text(
                                  'Extra: ${e.title} (£${e.amount.toStringAsFixed(2)})',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => onRemoveExtra(i, eIndex),
                                ),
                              );
                            }),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () => onRemoveItem(i),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onRemoveDiscount(),
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
                Checkbox(value: isPrintChecked, onChanged: onPrintToggle),
                const Text('Print'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    icon: const Icon(Icons.percent, size: 24),
                    label: const Text('Add Discount'),
                    onPressed: onAddDiscount,
                    // _openDiscountDialog,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    icon: const Icon(Icons.add_circle, size: 24),
                    label: const Text('Add item'),
                    onPressed: onAddItem//(){},
                    // _openDiscountDialog,
                  ),
                 ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    icon: const Icon(Icons.payment, size: 24),
                    label: const Text('Submit Cash'),
                    onPressed: onSubmitCash,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    icon: const Icon(Icons.payment, size: 24),
                    label: const Text('Submit Card'),
                    onPressed: onSubmitCard,
                  ),
                ]
            ),
            
          ],
        ),
      );
  }
}
