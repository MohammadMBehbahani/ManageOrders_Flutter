class ManagementItem {
  final String title;
  final String routeName;

  const ManagementItem({required this.title, required this.routeName});
}

class ManagementItems {
  static const List<ManagementItem> all = [
    ManagementItem(title: 'Category', routeName: '/category_screen'),
    ManagementItem(title: 'Extra', routeName: '/extra_screen'),
    ManagementItem(title: 'product_screen', routeName: '/product_screen'),
    ManagementItem(title: 'Add topping', routeName: '/topping_screen'),
    ManagementItem(title: 'Shop details', routeName: '/shope_detail_screen'),
    ManagementItem(
      title: 'Manage Left Order View',
      routeName: '/manage_left_view_screen',
    ),
    ManagementItem(title: 'Drawer Logs', routeName: '/drawer_logs'),
  ];
}
