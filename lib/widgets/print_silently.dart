import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
