import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:manageorders/models/product.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:manageorders/models/order.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:manageorders/providers/product_provider.dart';

class PrintOrderWidget extends ConsumerWidget {
  final Order order;

  const PrintOrderWidget({super.key, required this.order});

  Future<Uint8List> generatePdf(
    Order order,
    List<Product> products, [
    PdfPageFormat? format,
  ]) async {
    final pageFormat = PdfPageFormat(
      227, // width in points (80 mm ≈ 3.15 inch * 72)
      400, // height in points (change based on receipt length, or set large for scroll)
      marginAll: 5, // optional margins in points
    );
    
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final shortOrderId = order.id.replaceAll(RegExp(r'\D'), '');

    // Group items by productId
    final Map<String, List<OrderItem>> grouped = {};
    for (final item in order.items) {
      grouped.putIfAbsent(item.productId, () => []).add(item);
    }

    double subtotal = order.items.fold(0, (sum, i) => sum + i.totalPrice);
    double discountAmount = 0;
    String discountText = '';
    if (order.discount != null) {
      if (order.discount!.type == 'percentage') {
        discountAmount = subtotal * (order.discount!.value / 100);
        discountText = '${order.discount!.value.toStringAsFixed(2)}% off';
      } else {
        discountAmount = order.discount!.value;
        discountText = '£${order.discount!.value.toStringAsFixed(2)} off';
      }
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Caspian',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('123 Main Street'),
              pw.Text('Suite 4B'),
              pw.Text('Business Park'),
              pw.Text('AB12 3CD Countyshire'),
              pw.Text('01234 567890'),
              pw.SizedBox(height: 12),
              pw.Text('Order Number: $shortOrderId'),
              pw.SizedBox(height: 8),
              ...grouped.entries.expand((entry) {
                final items = entry.value;
                final productName = products
                    .firstWhere((p) => p.id == entry.key)
                    .name;

                return [
                  pw.Text(
                    productName,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  ...items.map((item) {
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${item.quantity} x ${item.subProductName}'),
                        pw.Text('£${item.unitPrice.toStringAsFixed(2)}'),
                      ],
                    );
                  }),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total:'),
                      pw.Text(
                        '£${items.fold(0.0, (sum, i) => sum + i.totalPrice).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  pw.Divider(),
                ];
              }),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('£${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              if (order.discount != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Discount ($discountText):',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('-£${discountAmount.toStringAsFixed(2)}'),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('£${order.finalTotal.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Payment: ${order.paymentMethod.toUpperCase()}'),
              pw.Text('Date: ${dateFormat.format(order.createdAt)}'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productProvider);

    return productsAsync.when(
      data: (products) {
        return PdfPreview(
          build: (format) => generatePdf(order, products, format),
          canChangePageFormat: false,
          allowPrinting: true,
          allowSharing: false,
          initialPageFormat: PdfPageFormat.roll80,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
