import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});
