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
    AppMenuItem(title: 'Category', icon: Icons.home, routeName: '/category_screen'),
    AppMenuItem(title: 'Extra', icon: Icons.attach_money, routeName: '/extra_screen'),
    AppMenuItem(title: 'product_screen', icon: Icons.add, routeName: '/product_screen'),
    AppMenuItem(title: 'Add topping', icon: Icons.add, routeName: '/topping_screen'),
    AppMenuItem(title: 'order_screen', icon: Icons.category, routeName: '/order_screen'),
     AppMenuItem(title: 'order_list_screen', icon: Icons.notifications, routeName: '/order_list_screen'),
    // AppMenuItem(title: 'Profile', icon: Icons.person, routeName: '/user_profile'),
  ];
}