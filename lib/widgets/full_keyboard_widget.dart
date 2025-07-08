import 'package:flutter/material.dart';

class FullKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onKeyTap;

  const FullKeyboard({
    super.key,
    required this.controller,
    required this.onKeyTap,
  });

  void _handleKey(String key) {
    if (key == '⌫') {
      if (controller.text.isNotEmpty) {
        controller.text = controller.text.substring(0, controller.text.length - 1);
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    } else if (key == 'SPACE') {
      controller.text += ' ';
    } else if (key == 'ENTER') {
      controller.text += '\n';
    } else {
      controller.text += key;
    }

    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    onKeyTap(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
      ['@', '#', '\$', '%', '&', '*', '(', ')', '-', '_','.'],
      ['⌫', 'SPACE', 'ENTER'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((char) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () => _handleKey(char),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  char,
                  style: const TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
