import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/widgets/menu/app_drawer.dart';
import 'package:manageorders/widgets/time_display_widget.dart';

class LayoutScreen extends ConsumerWidget {
  final Widget body;
  final String title;

  const LayoutScreen({super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Text(title),
            SizedBox(width: 10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TimeDisplayWidget(),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(child: body),
    );
  }
}
