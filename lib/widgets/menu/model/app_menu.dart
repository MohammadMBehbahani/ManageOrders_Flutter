import 'package:flutter/material.dart';

class AppMenuItem {
  final String title;
  final IconData icon;
  final String routeName;

  const AppMenuItem({
    required this.title,
    required this.icon,
    required this.routeName,
  });
}

class AppMenuItems {
  static const List<AppMenuItem> all = [
    AppMenuItem(
      title: 'Home',
      icon: Icons.home,
      routeName: '/home_screen',
    ),
    AppMenuItem(
      title: 'Order List',
      icon: Icons.list_alt,
      routeName: '/order_list_screen',
    ),
    AppMenuItem(
      title: 'Management',
      icon: Icons.settings,
      routeName: '/management_screen',
    ),
  ];
}
