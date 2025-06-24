import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/widgets/menu/model/app_menu.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

   void _navigateIfNotCurrent(
    BuildContext context,
    WidgetRef ref,
    String screenName,
  ) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current != screenName) {
      Navigator.of(context).pushReplacementNamed(screenName);
    } else {
      Navigator.pop(context); // just close drawer if already there
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          for (final item in AppMenuItems.all)
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () => _navigateIfNotCurrent(context, ref, item.routeName),
            )
         
        ],
      ),
    );
  }
}
