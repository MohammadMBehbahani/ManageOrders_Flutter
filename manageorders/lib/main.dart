import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/srcreen/category_screen.dart';
import 'package:manageorders/srcreen/extra_screen.dart';
import 'package:manageorders/srcreen/order/order_list_screen.dart';
import 'package:manageorders/srcreen/order/order_screen.dart';
import 'package:manageorders/srcreen/product/product_screen.dart';
import 'package:manageorders/srcreen/topping_screen.dart';

void main() {
  runApp(const ProviderScope(child: ManageOrdersApp()));
}

class ManageOrdersApp extends StatelessWidget {
  const ManageOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      initialRoute: '/category_screen',
      routes: {
        '/category_screen': (context) => const CategoryScreen(),
        '/extra_screen': (context) => const ExtraScreen(),
        '/product_screen': (context) => const ProductScreen(),
        '/topping_screen': (context) => const ToppingScreen(),
        '/order_screen': (context) => const OrderScreen(),
         '/order_list_screen': (context) => const SubmittedOrdersScreen(),
        // '/add-expense': (context) => const AddExpenseScreen(),
        // '/add-expense-category': (context) => const AddCategoryScreen(),
        // '/add-reminder': (context) => const AddReminderScreen(),
        // '/user_profile': (context) => const UserProfileScreen()
      }
    );
  }
}