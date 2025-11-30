//import 'dart:io';

 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/srcreen/category_screen.dart';
import 'package:manageorders/srcreen/drawer_log_screen.dart';
import 'package:manageorders/srcreen/extra_screen.dart';
import 'package:manageorders/srcreen/home_screen.dart';
import 'package:manageorders/srcreen/manage_left_view.dart';
import 'package:manageorders/srcreen/management/management_screen.dart';
import 'package:manageorders/srcreen/order/order_list_screen.dart';
import 'package:manageorders/srcreen/order/order_screen.dart';
import 'package:manageorders/srcreen/product/product_screen.dart';
import 'package:manageorders/srcreen/shope_details_screen.dart';
import 'package:manageorders/srcreen/topping_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   await windowManager.ensureInitialized();
  //   WindowOptions winopt = WindowOptions(fullScreen: true);
  //   windowManager.waitUntilReadyToShow(winopt, () async {
  //     await windowManager.setFullScreen(true);
  //   });
  // }

  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   sqfliteFfiInit();
  //   databaseFactory = databaseFactoryFfi;
  // }
  runApp(const ProviderScope(child: ManageOrdersApp()));

// runApp(const MyTestApp());
}

class ManageOrdersApp extends StatelessWidget {
  const ManageOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
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
        '/shope_detail_screen': (context) => const ShopDetailsScreen(),
        '/manage_left_view_screen': (context) => const ManageLeftViewScreen(),
         '/drawer_logs': (context) => const DrawerLogsScreen()
        
      },
    );
  }
}

