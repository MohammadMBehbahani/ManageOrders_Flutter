import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manageorders/widgets/number_pad.dart';
import 'package:manageorders/widgets/print_order.dart';
import 'package:manageorders/models/order.dart'; // if you have it

class CashPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final bool isPrintChecked;
  final Future<Order> Function() onSubmit;

  const CashPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.isPrintChecked,
    required this.onSubmit,
  });

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  String givenCash = '';
  double? returnAmount;

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'C') {
        givenCash = '';
      } else if (key == '⌫') {
        if (givenCash.isNotEmpty) {
          givenCash = givenCash.substring(0, givenCash.length - 1);
        }
      } else {
        givenCash += key;
      }
    });
  }
  Future<void> openCashDrawer() async {
    try {
      final result = await Process.run('OpenDrawer.exe', []);

      if (result.exitCode == 0) {
       // print('✅ Drawer opened: ${result.stdout}');
      } else {
        if (!mounted) return;
      //  _showErrorDialog(context, 'Failed to open drawer:\n${result.stderr}');
      }
    } catch (e) {
      if (!mounted) return;
     // _showErrorDialog(context, 'Exception occurred:\n$e');
    }
  }
  //  void _showErrorDialog(BuildContext context, String message) {
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


  Future<void> _handleSubmit() async {
    final cash = double.tryParse(givenCash);
    final order = await widget.onSubmit();

    await openCashDrawer();

    if (!mounted) return;

    if (cash != null && cash >= widget.totalAmount) {
      final change = (cash - widget.totalAmount).toStringAsFixed(2);
      setState(() {
        returnAmount = double.parse(change);
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Change to return"),
          content: Text("£$change"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close change dialog
                Navigator.of(context).pop(); // close cash screen
                if (widget.isPrintChecked) {
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
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
      if (widget.isPrintChecked) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Total: £${widget.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            Text("Given Cash: £$givenCash", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Submit Payment', style: TextStyle(fontSize: 50, color: Colors.green),),
            ),
            const SizedBox(height: 12),
            Expanded(child: NumberPad(onKeyTap: _onKeyTap)),
          ],
        ),
      ),
    );
  }
}
