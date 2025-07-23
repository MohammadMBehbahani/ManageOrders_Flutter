import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/main.dart';
import 'package:manageorders/models/order.dart';
import 'package:manageorders/providers/submitted_order_provider.dart';
import 'package:intl/intl.dart';
import 'package:manageorders/srcreen/order/order_screen.dart';
import 'package:manageorders/srcreen/shared/layout_screen.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';
import 'package:manageorders/widgets/printer_cashdrawer_manager.dart';

class SubmittedOrdersScreen extends ConsumerStatefulWidget {
  const SubmittedOrdersScreen({super.key});

  @override
  ConsumerState<SubmittedOrdersScreen> createState() =>
      _SubmittedOrdersScreenState();
}

class _SubmittedOrdersScreenState extends ConsumerState<SubmittedOrdersScreen>
    with RouteAware {
  Order? selectedOrder;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    ref.read(submittedOrdersProvider.notifier).refreshOrders();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(submittedOrdersProvider.notifier).refreshOrders();
    });
  }

  void refresh() {
    final notifier = ref.read(submittedOrdersProvider.notifier);

    setState(() {
      toDate = null;
      fromDate = null;
      selectedOrder = null;
    });
    notifier.refreshOrders();
  }

  Future<void> _pickDateTime(BuildContext context, bool isFrom) async {
    final initial = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    if (context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime == null) return;

      final fullDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        if (isFrom) {
          fromDate = fullDateTime;
        } else {
          toDate = fullDateTime;
        }
      });
    }
  }

  void _printOrder(Order order) async {
    if (!mounted) return;
    await printOrderSilently(context: context, ref: ref, order: order);
    refresh();
  }

  void _printAll() async {
    final orders = await ref.read(submittedOrdersProvider.future);
    if (orders.isEmpty) return;
    if (!mounted) return;
    final shouldPrint = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Print Orders"),
        content: const Text("Do you want to print all submitted orders?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    // Only print if confirmed
    if (shouldPrint == true) {
      if (!mounted) return;
      await printOrdersSilently(context: context, ref: ref, orders: orders);
      await ref.read(submittedOrdersProvider.notifier).clearAll();
    }
    refresh();
  }

  void _editOrder(Order order) async {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OrderScreen(orderToEdit: order)));
    setState(() {
      toDate = null;
      fromDate = null;
      selectedOrder = null;
    });
    final notifier = ref.read(submittedOrdersProvider.notifier);
    notifier.refreshOrders();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(submittedOrdersProvider);
    final notifier = ref.read(submittedOrdersProvider.notifier);

    return LayoutScreen(
      title: 'Submitted Orders',
      body: Row(
        children: [
          // LEFT PANEL: Actions
          Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: selectedOrder != null
                      ? () => _printOrder(selectedOrder!)
                      : null,
                  child: const Text('Print Selected'),
                ),

                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: selectedOrder != null
                      ? () => _editOrder(selectedOrder!)
                      : null,
                  child: const Text('Edit Selected'),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async => _printAll(),
                  child: const Text('Print All'),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async => openCashDrawer(
                    ref,
                    reason: "Open Drawer: From Order List (Manual Open)",
                  ),
                  child: const Text('Open Drawer'),
                ),
              ],
            ),
          ),

          // RIGHT PANEL: Orders & Filters
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ordersAsync.when(
                    data: (orders) {
                      final filtered = orders.where((order) {
                        if (fromDate != null &&
                            order.createdAt.isBefore(fromDate!)) {
                          return false;
                        }
                        if (toDate != null &&
                            order.createdAt.isAfter(toDate!)) {
                          return false;
                        }
                        return true;
                      }).toList();

                      double total = 0;
                      double totalCash = 0;
                      double totalCard = 0;
                      double totalRefund = 0;

                      for (final order in filtered) {
                        final isRefunded = order.status == 'refunded';
                        if (isRefunded) {
                          totalRefund += order.finalTotal;
                        } else {
                          total += order.finalTotal;
                          if (order.paymentMethod == 'cash') {
                            totalCash += order.finalTotal;
                          } else if (order.paymentMethod == 'card') {
                            totalCard += order.finalTotal;
                          }
                        }
                      }

                      return Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _pickDateTime(context, true),
                            child: Text(
                              fromDate != null
                                  ? 'From: ${DateFormat.yMd().add_Hm().format(fromDate!)}'
                                  : 'Pick From',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _pickDateTime(context, false),
                            child: Text(
                              toDate != null
                                  ? 'To: ${DateFormat.yMd().add_Hm().format(toDate!)}'
                                  : 'Pick To',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              refresh();
                            },
                            child: const Text('Clear Filter'),
                          ),
                          const SizedBox(width: 18),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total: £${total.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 44),
                                  ),
                                  Text(
                                    'Cash: £${totalCash.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 44),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 58),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Card: £${totalCard.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 44),
                                  ),
                                  Text(
                                    'Refunds: -£${totalRefund.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 44),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                  ),
                ),

                Expanded(
                  child: ordersAsync.when(
                    data: (orders) {
                      final filtered =
                          orders.where((order) {
                            if (fromDate != null &&
                                order.createdAt.isBefore(fromDate!)) {
                              return false;
                            }
                            if (toDate != null &&
                                order.createdAt.isAfter(toDate!)) {
                              return false;
                            }
                            return true;
                          }).toList()..sort(
                            (a, b) => b.createdAt.compareTo(a.createdAt),
                          );

                      return ScrollWithTouch(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final order = filtered[i];
                            return ListTile(
                              tileColor: order.status == 'refunded'
                                  ? Colors.red.shade100
                                  : null,
                              selected: selectedOrder?.id == order.id,
                              selectedTileColor: Colors.grey.shade200,
                              title: Text(
                                'Order ${order.id.substring(0, 6)} - £${order.finalTotal.toStringAsFixed(2)}',
                              ),
                              subtitle: Text(
                                DateFormat.yMd().add_Hm().format(
                                  order.createdAt,
                                ),
                              ),
                              onTap: () =>
                                  setState(() => selectedOrder = order),
                              trailing: order.status == 'refunded'
                                  ? const Text(
                                      'Refunded',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Confirm Refund"),
                                            content: Text(
                                              "Are you sure you want to refund order ${order.id.substring(0, 6)}?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text("Refund"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await notifier.refundOrder(order.id);
                                        }
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.red,
                                      ),
                                      label: Text(
                                        'Refund',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
