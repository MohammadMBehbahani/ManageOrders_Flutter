import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/order.dart';
import 'package:manageorders/providers/submitted_order_provider.dart';
import 'package:intl/intl.dart';
import 'package:manageorders/srcreen/shared/layout_screen.dart';
import 'package:manageorders/widgets/print_all_orders.dart';
import 'package:manageorders/widgets/print_order.dart';

class SubmittedOrdersScreen extends ConsumerStatefulWidget {
  const SubmittedOrdersScreen({super.key});

  @override
  ConsumerState<SubmittedOrdersScreen> createState() =>
      _SubmittedOrdersScreenState();
}

class _SubmittedOrdersScreenState extends ConsumerState<SubmittedOrdersScreen> {
  Order? selectedOrder;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(submittedOrdersProvider.notifier).refreshOrders();
    });
  }

  Future<void> _pickDateTime(BuildContext context, bool isFrom) async {
    final initial = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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

  void _printOrder(Order order) {
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

  void _printAll() async {
    final orders = ref.read(submittedOrdersProvider).valueOrNull ?? [];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SizedBox(
          width: 500,
          height: 600,
          child: PrintAllOrdersWidget(orders: orders),
        ),
      ),
    );

    //orders.clear();
    await ref.read(submittedOrdersProvider.notifier).clearAll();
  }

  Future<void> openCashDrawer(BuildContext context) async {
    try {
      final result = await Process.run('windows\\OpenDrawer.exe', []);

      if (result.exitCode == 0) {
        print('✅ Drawer opened: ${result.stdout}');
      } else {
        _showErrorDialog(context, 'Failed to open drawer:\n${result.stderr}');
      }
    } catch (e) {
      _showErrorDialog(context, 'Exception occurred:\n$e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Drawer Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                  onPressed: () async => _printAll(),
                  child: const Text('Print All'),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async => openCashDrawer(context),
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
                  child: Row(
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
                          setState(() {
                            toDate = null;
                            fromDate = null;
                            selectedOrder = null;
                          });
                          notifier.refreshOrders();
                        },
                        child: const Text('Clear Filter'),
                      ),
                    ],
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

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final order = filtered[i];
                          return ListTile(
                            selected: selectedOrder?.id == order.id,
                            selectedTileColor: Colors.grey.shade200,
                            title: Text(
                              'Order ${order.id.substring(0, 6)} - £${order.finalTotal.toStringAsFixed(2)}',
                            ),
                            subtitle: Text(
                              DateFormat.yMd().add_Hm().format(order.createdAt),
                            ),
                            onTap: () => setState(() => selectedOrder = order),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async =>
                                  await notifier.deleteOrder(order.id),
                            ),
                          );
                        },
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
