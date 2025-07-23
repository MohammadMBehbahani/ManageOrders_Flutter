import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:manageorders/providers/time_provider.dart'; // optional for formatting

class TimeDisplayWidget extends ConsumerWidget {
  const TimeDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTimeAsync = ref.watch(currentTimeProvider);

    return currentTimeAsync.when(
      data: (time) => Text(
        DateFormat.Hms().format(time), // or use DateFormat('hh:mm:ss a') for 12-hour format
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red),
      ),
      loading: () => const Text('Loading...'),
      error: (e, st) => const Text('Error'),
    );
  }
}
