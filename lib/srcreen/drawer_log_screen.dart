import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:manageorders/main.dart';
import 'package:manageorders/providers/drawer_log_provider.dart';
import 'package:manageorders/widgets/time_display_widget.dart';

class DrawerLogsScreen extends ConsumerStatefulWidget {
  const DrawerLogsScreen({super.key});

  @override
  ConsumerState<DrawerLogsScreen> createState() => _DrawerLogsScreenState();
}

class _DrawerLogsScreenState extends ConsumerState<DrawerLogsScreen> with RouteAware {
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _clearOldLogs();
  }

  @override
  void didPopNext() {
    // Called when returning back to this screen
    _clearOldLogs();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _clearOldLogs() async {
    await ref.read(drawerLogsProvider.notifier).clearOldLogs(days: 2);
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initialDate = isFrom
        ? fromDate ?? DateTime.now().subtract(const Duration(days: 2))
        : toDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      if (isFrom) {
        fromDate = pickedDate;
      } else {
        toDate = pickedDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(drawerLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Drawer Logs'), 
      actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _pickDate(context, true),
                  child: Text(fromDate == null
                      ? 'From Date'
                      : 'From: ${DateFormat.yMd().format(fromDate!)}'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _pickDate(context, false),
                  child: Text(toDate == null
                      ? 'To Date'
                      : 'To: ${DateFormat.yMd().format(toDate!)}'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final filtered = logs.where((log) {
                  final date = log.dateTime;
                  if (fromDate != null && date.isBefore(fromDate!)) {
                    return false;
                  }
                  if (toDate != null && date.isAfter(toDate!)) {
                    return false;
                  }
                  return true;
                }).toList();

                filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));

                if (filtered.isEmpty) {
                  return const Center(child: Text('No logs found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    return ListTile(
                      title: Text(log.reason),
                      subtitle:
                          Text(DateFormat.yMd().add_Hm().format(log.dateTime)),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
