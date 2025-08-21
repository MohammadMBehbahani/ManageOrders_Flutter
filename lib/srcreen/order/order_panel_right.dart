import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/providers/manage_left_view_provider.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

class OrderRightPanel extends ConsumerStatefulWidget {
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

  final void Function(int itemIndex) onAddItemDiscount;
  final void Function(int itemIndex) onRemoveItemDiscount;
  final void Function(int itemIndex) onRemoveItem;
  final void Function(int itemIndex) onquantityInc;
  final void Function(int itemIndex) onquantityDec;
  final void Function(int itemIndex, int toppingIndex) onRemoveTopping;
  final void Function(int itemIndex, int extraIndex) onRemoveExtra;

  const OrderRightPanel({
    super.key,
    required this.onAddItemDiscount,
    required this.onRemoveItemDiscount,
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
  ConsumerState<OrderRightPanel> createState() => _OrderRightPanelState();
}

class _OrderRightPanelState extends ConsumerState<OrderRightPanel> {
  bool _isLoadingCard = false;

  Future _handleSubmitCard() async {
    setState(() => _isLoadingCard = true);
    try {
      widget.onSubmitCard;
    } finally {
      if (mounted) setState(() => _isLoadingCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(manageLeftViewProvider).value;
    final tottalfontsiz = (view == null || view.tottalfontsize <= 0)
        ? 18.0
        : view.tottalfontsize.toDouble();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ScrollWithTouch(
              child: ListView.builder(
                itemCount: widget.orderItems.length,
                itemBuilder: (_, i) {
                  final item = widget.orderItems[i];
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
                              item.itemDiscount > 0
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.red,
                                      ),
                                      tooltip: "Remove item discount",
                                      onPressed: () => widget.onRemoveItemDiscount(
                                        i,
                                      ), // or onRemoveItemDiscount if you separate
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.percent,
                                        color: Colors.blue,
                                      ),
                                      tooltip: "Add item discount",
                                      onPressed: () =>
                                          widget.onAddItemDiscount(i),
                                    ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.red,
                                ),
                                onPressed: () => widget.onquantityDec(i),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.green,
                                ),
                                onPressed: () => widget.onquantityInc(i),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () => widget.onRemoveItem(i),
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
                                  onPressed: () =>
                                      widget.onRemoveTopping(i, tIndex),
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
                                  onPressed: () =>
                                      widget.onRemoveExtra(i, eIndex),
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
          if (widget.selectedDiscount != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discount Applied: ${widget.selectedDiscount!.type} ${widget.selectedDiscount!.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => widget.onRemoveDiscount(),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Total: £${widget.finalTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: tottalfontsiz,
              ),
            ),
          ),

          Row(
            children: [
              Checkbox(
                value: widget.isPrintChecked,
                onChanged: widget.onPrintToggle,
              ),
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
                onPressed: widget.onAddDiscount,
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
                onPressed: widget.onAddItem, //(){},
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
            onPressed: widget.onSubmitCash,
          ),
          SizedBox(height: 10),

          _isLoadingCard
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 30),
                  ),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Submit Card'),
                  onPressed: _handleSubmitCard,
                ),
        ],
      ),
    );
  }
}
