import 'package:flutter/material.dart';
import 'package:manageorders/srcreen/shared/scroll_with_touch.dart';

class NumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;

  const NumberPad({super.key, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    final values = [
      ['10', '1', '2', '3'],
      ['20', '4', '5', '6'],
      ['30', '7', '8', '9'],
      ['40', '', '0', '.'],
      ['50', '60', '70', '80'],
      ['C', '⌫'], // Clear and Backspace
    ];

    final screenHeight = MediaQuery.of(context).size;
    final maxPadHeight = screenHeight.height * 0.58;
    final minPadHeight  = screenHeight.height - ((screenHeight.height * 95) / 100);

    final maxPadwidth = screenHeight.width;
    final minPadwidth  = screenHeight.width - ((screenHeight.width * 95) / 100);

    return SizedBox(
      height: maxPadHeight.clamp(minPadHeight, maxPadHeight),
      width: maxPadwidth.clamp(minPadwidth, maxPadwidth),
      child: ScrollWithTouch(
        child: SingleChildScrollView(
          child: Column(
            children: values.map((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((val) {
                  if (val.isEmpty) {
                    return  SizedBox(
                      width: maxPadwidth.clamp(minPadwidth, 120)
                    , height: maxPadHeight.clamp(minPadHeight, 75)
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ElevatedButton(
                      onPressed: () => onKeyTap(val),
                      style: ElevatedButton.styleFrom(
                        minimumSize:  Size(
                          maxPadwidth.clamp(minPadwidth, 120)
                          , maxPadHeight.clamp(minPadHeight, 75)
                          ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(val, style: const TextStyle(fontSize: 40)),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
