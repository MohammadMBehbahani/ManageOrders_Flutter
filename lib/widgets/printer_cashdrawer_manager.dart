import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/providers/drawer_log_provider.dart';
import 'package:manageorders/widgets/print_all_orders.dart';
import 'package:manageorders/widgets/print_order.dart';
import 'package:printing/printing.dart';
import 'package:manageorders/models/order.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/category_provider.dart';

Future<void> printOrderSilently({
  required BuildContext context,
  required WidgetRef ref,
  required Order order,
}) async {
  final products = await ref.read(productProvider.future);
  final categories = await ref.read(categoryProvider.future);

  try {
    final pdfData = await PrintOrderWidget(
      order: order,
    ).generatePdf(ref, order, products, categories);

    final printers = await Printing.listPrinters();
    final printer = printers.firstWhere(
      (p) => p.name.toLowerCase().contains("zj-80"),
      orElse: () => printers.first,
    );

    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (_) async => pdfData,
      name: 'Order_${order.id}',
    );
  } catch (e) {
    if (context.mounted) {
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
  }
}

Future<void> printOrdersSilently({
  required BuildContext context,
  required WidgetRef ref,
  required List<Order> orders,
}) async {
  try {
    final pdfData = await PrintAllOrdersWidget(orders: orders).generatePdf();

    final printers = await Printing.listPrinters();
    final printer = printers.firstWhere(
      (p) => p.name.toLowerCase().contains("zj-80"),
      orElse: () => printers.first,
    );

    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (_) async => pdfData,
      name: 'Order_${DateTime.now()}',
    );
  } catch (e) {
    if (context.mounted) {
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
    }
  }
}

Future<void> openCashDrawer(WidgetRef ref, {
  String printerName = 'ZJ-80',
  String reason = 'Manual Open',
}) async {
  try {
    
    await ref.read(drawerLogsProvider.notifier).addLogFromReason(reason);

    final result = await Process.run('OpenDrawer.exe', [printerName]);

    if (result.exitCode == 0) {
      // print('✅ Drawer opened: ${result.stdout}');
    } else {
      // if (!mounted) return;
      //_showErrorDialog(context, 'Exception occurred:\n$e');
    }
  } catch (e) {
    //if (!mounted) return;
    // _showErrorDialog(context, 'Exception occurred:\n$e');
  }
}

  // void _showErrorDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Drawer Error'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }