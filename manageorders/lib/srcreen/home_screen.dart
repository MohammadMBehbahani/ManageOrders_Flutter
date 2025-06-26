import 'package:flutter/material.dart';
import 'package:manageorders/srcreen/shared/layout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutScreen(
      title: 'Home',
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5, // Adjust width as needed
          heightFactor: 0.6,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.pushNamed(context, '/order_screen'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centers content
              children: [
                const Icon(Icons.receipt_long, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Start Order',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
