import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/widgets/number_pad.dart';
import 'package:manageorders/widgets/printer_cashdrawer_manager.dart';
import 'package:manageorders/widgets/time_display_widget.dart'; // if you have it

class CashPaymentScreen extends ConsumerStatefulWidget {
  final double totalAmount;
  const CashPaymentScreen({
    super.key,
    required this.totalAmount
  });

  @override
  ConsumerState<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends ConsumerState<CashPaymentScreen> {
  String givenCash = '';
  double? returnAmount;
  bool _isLoading = false;

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

  Future<void> _handleSubmit() async {
    if (widget.totalAmount <= 0) {
      return;
    }

    final cash = double.tryParse(givenCash);
    if (cash != null && cash <= 0) {
      return;
    }

    setState(() {
      _isLoading = true; // ✅ start loading
    });

    try {
      await openCashDrawer(
        ref,
        reason: "Open Drawer: Cash Payment",
      ); // Attempt to open drawer, ignore errors
    } catch (e) {
      debugPrint('⚠️ Failed to open drawer: $e'); // Log it or ignore silently
    }
    try {
      if (!mounted) return;
     

      if (cash != null && cash >= widget.totalAmount) {
        final change = (cash - widget.totalAmount).toStringAsFixed(2);
        setState(() {
          returnAmount = double.parse(change);
        });
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            title: const Text("Change to return"),
            content: Text("£$change", style: TextStyle(fontSize: 120)),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // close change dialog
                  Navigator.of(context).pop(widget.totalAmount);
                },
                child: const Text("OK", style: TextStyle(fontSize: 30)),
              ),
            ],
          ),
        );
      } else if (cash != null && cash < widget.totalAmount) {
        final remaining = widget.totalAmount - cash;
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Partial Payment"),
            content: Text(
              "Received £$cash\nRemaining: £$remaining\n\nDo you want to pay the rest by card?",
              style: const TextStyle(fontSize: 22),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // close dialog
                   Navigator.of(context).pop(remaining);
                },
                child: const Text("Pay Remaining by Card"),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(widget.totalAmount);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // ✅ stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Payment'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Total: £${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              "Given Cash: £$givenCash",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator() // ✅ show loader
                : ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text(
                      'Submit Payment',
                      style: TextStyle(fontSize: 50, color: Colors.green),
                    ),
                  ),
            const SizedBox(height: 12),
            Expanded(child: NumberPad(onKeyTap: _onKeyTap)),
          ],
        ),
      ),
    );
  }
}
