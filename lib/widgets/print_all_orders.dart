import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:manageorders/models/order.dart';

class PrintAllOrdersWidget extends StatelessWidget {
  final List<Order> orders;

  const PrintAllOrdersWidget({super.key, required this.orders});

  Future<Uint8List> generatePdf([PdfPageFormat? format]) async {
   final pageFormat = PdfPageFormat(
      227, // width in points (80 mm ≈ 3.15 inch * 72)
      400, // height in points (change based on receipt length, or set large for scroll)
      marginAll: 5, // optional margins in points
    );

    final currency = NumberFormat.simpleCurrency(locale: 'en_GB');

    final double totalAmount =
        orders.fold(0, (sum, o) => sum + o.finalTotal);

    final double cashTotal = orders
        .where((o) => o.paymentMethod.toLowerCase() == 'cash')
        .fold(0, (sum, o) => sum + o.finalTotal);

    final double cardTotal = orders
        .where((o) => o.paymentMethod.toLowerCase() == 'card')
        .fold(0, (sum, o) => sum + o.finalTotal);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Taking Analysis',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),

            pw.Text('Description and Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),

            _row('Takeaway', currency.format(totalAmount)),
            pw.SizedBox(height: 12),

            pw.Text('Sale by Payment Method',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Cash', currency.format(cashTotal)),
            _row('Card', currency.format(cardTotal)),
            pw.SizedBox(height: 12),

            pw.Text('Total Vat Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('VAT Amount', currency.format(0)),
            pw.SizedBox(height: 12),

            pw.Text('Total Cash in Drawer',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Cash in Drawer', currency.format(cashTotal)),
            pw.SizedBox(height: 12),

            pw.Text('Net Amount',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _row('Net Sale', currency.format(totalAmount)),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _row(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title),
        pw.Text(value),
        pw.SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (format) => generatePdf(format),
      canChangePageFormat: false,
      allowPrinting: true,
      allowSharing: false,
      initialPageFormat: PdfPageFormat.a4,
    );
  }
}
