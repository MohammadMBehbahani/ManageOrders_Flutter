import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/srcreen/category_screen.dart';
import 'package:manageorders/srcreen/extra_screen.dart';
import 'package:manageorders/srcreen/home_screen.dart';
import 'package:manageorders/srcreen/management/management_screen.dart';
import 'package:manageorders/srcreen/order/order_list_screen.dart';
import 'package:manageorders/srcreen/order/order_screen.dart';
import 'package:manageorders/srcreen/product/product_screen.dart';
import 'package:manageorders/srcreen/topping_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const ProviderScope(child: ManageOrdersApp()));
}

class ManageOrdersApp extends StatelessWidget {
  const ManageOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      initialRoute: '/home_screen',
      routes: {
        '/home_screen': (context) => const HomeScreen(),
        '/category_screen': (context) => const CategoryScreen(),
        '/extra_screen': (context) => const ExtraScreen(),
        '/product_screen': (context) => const ProductScreen(),
        '/topping_screen': (context) => const ToppingScreen(),
        '/order_screen': (context) => const OrderScreen(),
        '/order_list_screen': (context) => const SubmittedOrdersScreen(),
        '/management_screen': (context) => const ManagementScreen(),
      },
    );
  }
}
