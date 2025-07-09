import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:manageorders/models/category.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/providers/category_provider.dart';
import 'package:manageorders/providers/shop_details_provider.dart';
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

  pw.Widget _buildItemBlock(OrderItem item) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text('${item.quantity} x ${item.subProductName}'),
             pw.SizedBox(width: 50),
            pw.Text('£${item.unitPrice.toStringAsFixed(2)}'),
          ],
        )
        
      ],
    );
  }

  Future<Uint8List> generatePdf(
    WidgetRef ref,
    Order order,
    List<Product> products,
    List<Category> categories, [
    PdfPageFormat? format,
  ]) async {
    final shopDetailsAsync = await ref.watch(shopDetailsProvider.future);

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
      grouped.putIfAbsent(item.product.id, () => []).add(item);
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
                  shopDetailsAsync?.shopName != null
                      ? shopDetailsAsync!.shopName
                      : '',
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                shopDetailsAsync?.address1 != null
                    ? shopDetailsAsync!.address1
                    : '',
              ),
              pw.Text(
                shopDetailsAsync?.address2 != null
                    ? shopDetailsAsync!.address2
                    : '',
              ),
              pw.Text(
                shopDetailsAsync?.address3 != null
                    ? shopDetailsAsync!.address3
                    : '',
              ),
              pw.Row(
                children: [
                  pw.Text(
                    shopDetailsAsync?.address4 != null
                        ? shopDetailsAsync!.address4
                        : '',
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    shopDetailsAsync?.postcode != null
                        ? shopDetailsAsync!.postcode
                        : '',
                  ),
                ],
              ),
              pw.Text(
                shopDetailsAsync?.phone != null ? shopDetailsAsync!.phone : '',
              ),
              pw.SizedBox(height: 12),
              pw.Text('Order Number: $shortOrderId'),
              pw.SizedBox(height: 8),
              ...categories.map((category) {
                final categoryProducts = products.where(
                  (p) => p.categoryId == category.id,
                );

                final itemsInCategory = order.items.where(
                  (item) =>
                      categoryProducts.any((p) => p.id == item.product.id),
                );
                if (itemsInCategory.isEmpty) {
                  return pw.SizedBox(); // skip empty categories
                }

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      category.name,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    ...categoryProducts.map((product) {
                      final productItems = order.items
                          .where((item) => item.product.id == product.id)
                          .toList();

                      if (productItems.isEmpty) return pw.SizedBox();

                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            product.name,
                            style: pw.TextStyle(fontSize: 11),
                          ),
                          ...productItems.map((item) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Text(
                                      '${item.quantity} x ${item.subProductName}',
                                    ),
                                    pw.SizedBox(width: 50),
                                    pw.Text(
                                      '£${item.unitPrice.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                                if (item.extras?.isNotEmpty ?? false)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                      left: 12,
                                      top: 2,
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: item.extras!.map((extra) {
                                        return pw.Text(
                                          '+ Extra: ${extra.title} (£${extra.amount.toStringAsFixed(2)})',
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                if (item.toppings?.isNotEmpty ?? false)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                      left: 12,
                                      top: 2,
                                    ),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: item.toppings!.map((topping) {
                                        return pw.Text(
                                          '+ Topping: ${topping.name} (£${topping.price.toStringAsFixed(2)})',
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                pw.SizedBox(height: 6),
                              ],
                            );
                          }),
                        ],
                      );
                    }),
                    pw.Divider(), // 👈 this now separates the **category**
                  ],
                );
              }),

              () {
                final knownProductIds = products.map((p) => p.id).toSet();

                final unmatchedItems = order.items.where(
                  (item) => !knownProductIds.contains(item.product.id),
                );

                if (unmatchedItems.isEmpty) return pw.SizedBox();

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Custom Items',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    ...unmatchedItems.map((item) => _buildItemBlock(item)),
                    pw.Divider(),
                  ],
                );
              }(),

              pw.Row(
                children: [
                  pw.Text('Subtotal:'),
                  pw.SizedBox(width: 20),
                  pw.Text('£${subtotal.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 10),
                ],
              ),
              if (order.discount != null)
                pw.Row(
                  
                  children: [
                    pw.Text('Discount ($discountText):'),
                    pw.SizedBox(width: 50),
                    pw.Text('-£${discountAmount.toStringAsFixed(2)}'),
                    pw.SizedBox(height: 8),
                  ],
                ),
              pw.Row(
                
                children: [
                  pw.Text('Total:'),
                  pw.SizedBox(width: 36),
                  pw.Text('£${order.finalTotal.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 8),
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
    final categoryAsync = ref.watch(categoryProvider);

    return productsAsync.when(
      data: (products) {
        return categoryAsync.when(
          data: (categories) {
            return PdfPreview(
              build: (format) =>
                  generatePdf(ref, order, products, categories, format),
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: false,
              initialPageFormat: PdfPageFormat.roll80,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
