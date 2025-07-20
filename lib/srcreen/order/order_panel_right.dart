import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/providers/manage_left_view_provider.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

class OrderRightPanel extends ConsumerWidget {
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
  final void Function(int itemIndex) onquantityInc;
  final void Function(int itemIndex) onquantityDec;
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
    required this.onquantityInc,
    required this.onquantityDec,
    required this.onRemoveTopping,
    required this.onRemoveExtra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(manageLeftViewProvider).value;
    final tottalfontsiz =
        (view == null ||
            view.tottalfontsize <= 0)
        ? 18.0
        : view.tottalfontsize.toDouble();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ScrollWithTouch(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (_, i) {
                  final item = orderItems[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.product.name} - ${item.subProductName} x${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            softWrap: true, // Enables wrapping
                            overflow: TextOverflow
                                .visible, // Or ellipsis if you want "..."
                          ),

                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('£${item.totalPrice.toStringAsFixed(2)}'),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.red,
                                ),
                                onPressed: () => onquantityDec(i),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.green,
                                ),
                                onPressed: () => onquantityInc(i),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () => onRemoveItem(i),
                              ),
                            ],
                          ),

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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(thickness: 10),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: tottalfontsiz,
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
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 2,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.percent, size: 18),
                label: const Text('Add Discount'),
                onPressed: onAddDiscount,
                // _openDiscountDialog,
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 2,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.add_circle, size: 18),
                label: const Text('Add item'),
                onPressed: onAddItem, //(){},
                // _openDiscountDialog,
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 30),
            ),
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('Submit Cash'),
            onPressed: onSubmitCash,
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 30),
            ),
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('Submit Card'),
            onPressed: onSubmitCard,
          ),
        ],
      ),
    );
  }
}
