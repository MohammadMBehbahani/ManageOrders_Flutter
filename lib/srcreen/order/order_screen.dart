import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/order.dart';
import 'package:manageorders/models/order_extra.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:manageorders/models/order_topping.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/providers/category_provider.dart';
import 'package:manageorders/providers/extra_provider.dart';
import 'package:manageorders/providers/product_provider.dart';
import 'package:manageorders/providers/order_provider.dart';
import 'package:manageorders/providers/submitted_order_provider.dart';
import 'package:manageorders/providers/topping_provider.dart';
import 'package:manageorders/srcreen/order/order_panel_left.dart';
import 'package:manageorders/srcreen/order/order_panel_right.dart';
import 'package:manageorders/srcreen/order/orderwidget/add_item_screen.dart';
import 'package:manageorders/srcreen/order/orderwidget/cash_payment_screen.dart';
import 'package:manageorders/srcreen/order/orderwidget/discount_select_screen.dart';
import 'package:manageorders/srcreen/order/orderwidget/extra_select_screen.dart';
import 'package:manageorders/srcreen/order/orderwidget/sub_product_widget.dart';
import 'package:manageorders/srcreen/order/orderwidget/topping_select_screen.dart';
import 'package:manageorders/widgets/printer_cashdrawer_manager.dart';
import 'package:uuid/uuid.dart';

class OrderScreen extends ConsumerStatefulWidget {
  final Order? orderToEdit;

  const OrderScreen({super.key, this.orderToEdit});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  Order? get editingOrder => widget.orderToEdit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editingOrder != null) {
        ref.read(orderProvider.notifier).updateItems(editingOrder!.items);
        setState(() {
          selectedCategoryId = editingOrder!.items.first.product.categoryId;
          // Optionally set product, sub-product, extras, etc.
        });
      } else {
        ref.read(orderProvider.notifier).clearOrder();
      }
    });
  }

  String? selectedCategoryId;
  Product? selectedProduct;
  SubProductOption? selectedSubProduct;
  List<OrderExtra> selectedExtras = [];
  List<OrderTopping> selectedToppings = [];
  Discount? selectedDiscount;
  bool isPrintChecked = false;

  //add Item
  Future<void> _addSimpleItem() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddOrderItemProductScreen()),
    );

    if (result != null) {
      final name = result['name'] as String;
      final price = result['price'] as double;

      final item = OrderItem(
        product: Product(
          id: const Uuid().v4(),
          categoryId: selectedCategoryId!,
          name: name,
          basePrice: price,
        ),
        subProductName: '',
        quantity: 1,
        unitPrice: price,
        extras: null,
        toppings: null,
      );
      ref.read(orderProvider.notifier).addItem(item);

      setState(() {
        selectedProduct = null;
        selectedSubProduct = null;
        selectedExtras = [];
        selectedToppings = [];
      });
    }
  }

  // Discount dialog
  Future<void> _openDiscountDialog() async {
    final discount = await Navigator.push<Discount>(
      context,
      MaterialPageRoute(builder: (_) => const DiscountSelectScreen()),
    );

    if (discount != null) {
      setState(() {
        selectedDiscount = discount;
      });
    }
  }

  // Add Topping dialog
  Future<void> _openToppingDialog() async {
    final toppingList = await ref.watch(toppingProvider.future);
    if (mounted) {
      final topping = await Navigator.push<OrderTopping>(
        context,
        MaterialPageRoute(
          builder: (_) => ToppingSelectScreen(availableToppings: toppingList),
        ),
      );

      if (topping != null) {
        setState(() {
          selectedToppings.add(topping);
        });
      }
    }
  }

  // Add Extra dialog
  Future<void> _openExtraDialog() async {
    final availableExtras = await ref.watch(extraProvider.future);

    if (mounted) {
      final addedExtra = await Navigator.push<OrderExtra>(
        context,
        MaterialPageRoute(
          builder: (_) => ExtraSelectScreen(availableExtras: availableExtras),
        ),
      );
      if (addedExtra != null) {
        setState(() {
          selectedExtras.add(addedExtra);
        });
      }
    }
  }

  void _addCurrentItemToOrder() async {
    final String subProductName;
    final double unitPrice;

    if (selectedProduct == null && selectedSubProduct == null) {
      return;
    } else if (selectedProduct != null &&
        selectedSubProduct == null &&
        selectedProduct!.availableSubProducts.isNotEmpty) {
      return;
    } else if (selectedProduct != null &&
        selectedSubProduct == null &&
        selectedProduct!.availableSubProducts.isEmpty) {
      subProductName = selectedProduct!.name;
      unitPrice = selectedProduct!.basePrice;
    } else {
      subProductName = selectedSubProduct!.name;
      unitPrice =
          selectedProduct!.basePrice + selectedSubProduct!.additionalPrice;
    }

    final products = await ref.watch(productProvider.future);
    final product = products.firstWhere((p) => p.id == selectedProduct!.id);

    final item = OrderItem(
      product: product,
      subProductName: subProductName,
      quantity: 1,
      unitPrice: unitPrice,
      extras: [...selectedExtras],
      toppings: [...selectedToppings],
    );

    ref.read(orderProvider.notifier).addItem(item);

    setState(() {
      selectedProduct = null;
      selectedSubProduct = null;
      selectedExtras = [];
      selectedToppings = [];
    });
  }

  Future<void> _submitOrder(String paymentMethod) async {
    final order = ref
        .read(orderProvider.notifier)
        .getDraftOrder(
          discount: selectedDiscount,
          paymentMethod: paymentMethod,
        );
    if(order.finalTotal <= 0){
      return;
    }
    if (paymentMethod == 'cash') {
      final total = order.finalTotal;
      await Navigator.of(context).push<Order>(
        MaterialPageRoute(
          builder: (_) => CashPaymentScreen(
            totalAmount: total,
            onSubmit: () => ref
                .read(orderProvider.notifier)
                .submitOrder(
                  paymentMethod: paymentMethod,
                  discount: selectedDiscount,
                ),
          ),
        ),
      );

      if (isPrintChecked) {
        if (!mounted) return;
        await printOrderSilently(context: context, ref: ref, order: order);
      }
      setState(() {
        selectedDiscount = null;
        isPrintChecked = false;
      });
      return;
    }
    await ref
        .read(orderProvider.notifier)
        .submitOrder(paymentMethod: paymentMethod, discount: selectedDiscount);
    if (isPrintChecked) {
      if (!mounted) return;
      await printOrderSilently(context: context, ref: ref, order: order);
    }
    if (editingOrder != null) {
      final notifier = ref.read(submittedOrdersProvider.notifier);
      await notifier.deleteOrder(editingOrder!.id);
    }

    setState(() {
      selectedDiscount = null;
      isPrintChecked = false;
    });
  }

  void onCategorySelect(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      selectedProduct = null;
      selectedSubProduct = null;
      selectedExtras = [];
      selectedToppings = [];
    });
  }

  void onProductSelect(Product product) async {
    setState(() {
      selectedProduct = product;
      selectedSubProduct = null;
      selectedExtras = [];
      selectedToppings = [];
    });

    // Delay just a tick to ensure UI updates (optional safety)
    await Future.delayed(Duration.zero);

    if (product.availableSubProducts.isNotEmpty) {
      List<SubProductOption> sortedSubProducts = [];
      if (selectedProduct != null) {
        sortedSubProducts = [...selectedProduct!.availableSubProducts]
          ..sort((a, b) {
            if (a.priority == null && b.priority == null) return 0;
            if (a.priority == null) return 1;
            if (b.priority == null) return -1;
            return a.priority!.compareTo(b.priority!);
          });
      }

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubProductExtrasScreen(
            subProducts: sortedSubProducts,
            selectedSubProduct: selectedSubProduct,
            selectedExtras: selectedExtras,
            selectedToppings: selectedToppings,
            onSubProductSelect: onSubProductSelect,
            onAddExtra: _openExtraDialog,
            onAddTopping: _openToppingDialog,
            onRemoveExtra: onRemoveExtra,
            onRemoveTopping: onRemoveTopping,
          ),
        ),
      );
    } else {
      _addCurrentItemToOrder();
    }
  }

  void onSubProductSelect(SubProductOption subProduct) {
    setState(() => selectedSubProduct = subProduct);
    _addCurrentItemToOrder();
  }

  void onRemoveExtra(int index) {
    setState(() {
      selectedExtras.removeAt(index);
    });
  }

  void onRemoveTopping(int index) {
    setState(() {
      selectedToppings.removeAt(index);
    });
  }

  void onRemoveDiscount() {
    setState(() {
      selectedDiscount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider).valueOrNull ?? [];

    if (selectedCategoryId == null && categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedCategoryId = categories.first.id;
        });
      });
    }

    final products = ref.watch(productProvider).valueOrNull ?? [];
    final orderItems = ref.watch(orderProvider);
    final List<Product> filteredProducts = selectedCategoryId == null
        ? []
        : products.where((p) => p.categoryId == selectedCategoryId).toList();

    // Calculate total with discount
    double subtotal = 0.0;
    for (var item in orderItems) {
      double toppingTotal = 0.0;
      if (item.toppings != null) {
        toppingTotal = item.toppings!.fold(0, (sum, t) => sum + t.price);
      }
      double extraTotal = 0.0;
      if (item.extras != null) {
        extraTotal = item.extras!.fold(0, (sum, e) => sum + e.amount);
      }
      subtotal += (item.unitPrice + toppingTotal + extraTotal) * item.quantity;
    }

    double finalTotal = subtotal;
    if (selectedDiscount != null) {
      if (selectedDiscount!.type == 'percentage') {
        finalTotal = subtotal * (1 - selectedDiscount!.value / 100);
      } else if (selectedDiscount!.type == 'flat') {
        finalTotal = (subtotal - selectedDiscount!.value).clamp(
          0,
          double.infinity,
        );
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF1A1E24),
      appBar: AppBar(
        title: const Text(
          'Create Order',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1A1E24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // LEFT PANEL
              Expanded(
                flex: 6,
                child: OrderLeftPanel(
                  onAddToOrder: _addCurrentItemToOrder,
                  onAddExtra: _openExtraDialog,
                  onAddTopping: _openToppingDialog,
                  categories: categories,
                  filteredProducts: filteredProducts,
                  selectedCategoryId: selectedCategoryId,
                  selectedProduct: selectedProduct,
                  selectedSubProduct: selectedSubProduct,
                  selectedExtras: selectedExtras,
                  selectedToppings: selectedToppings,
                  onCategorySelect: onCategorySelect,
                  onProductSelect: onProductSelect,
                  onSubProductSelect: onSubProductSelect,
                  onRemoveExtra: onRemoveExtra,
                  onRemoveTopping: onRemoveTopping,
                ),
              ),

              // RIGHT PANEL (Order summary)
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.white,
                  child: OrderRightPanel(
                    onquantityInc: (index) => ref
                        .read(orderProvider.notifier)
                        .increaseQuantity(index),
                    onquantityDec: (index) => ref
                        .read(orderProvider.notifier)
                        .decreaseQuantity(index),
                    orderItems: orderItems,
                    onAddItem: _addSimpleItem,
                    selectedDiscount: selectedDiscount,
                    finalTotal: finalTotal,
                    isPrintChecked: isPrintChecked,
                    onPrintToggle: (value) =>
                        setState(() => isPrintChecked = value ?? false),
                    onAddDiscount: _openDiscountDialog,
                    onRemoveDiscount: onRemoveDiscount,
                    onSubmitCash: () async => await _submitOrder('cash'),
                    onSubmitCard: () async => _submitOrder('card'),
                    onRemoveItem: (index) =>
                        ref.read(orderProvider.notifier).removeItem(index),
                    onRemoveTopping: (itemIndex, toppingIndex) {
                      final item = orderItems[itemIndex];
                      final newToppings = [...item.toppings!]
                        ..removeAt(toppingIndex);
                      final updated = item.copyWith(toppings: newToppings);
                      final updatedItems = [...orderItems];
                      updatedItems[itemIndex] = updated;
                      ref
                          .read(orderProvider.notifier)
                          .updateItems(updatedItems);
                    },
                    onRemoveExtra: (itemIndex, extraIndex) {
                      final item = orderItems[itemIndex];
                      final newExtras = [...item.extras!]..removeAt(extraIndex);
                      final updated = item.copyWith(extras: newExtras);
                      final updatedItems = [...orderItems];
                      updatedItems[itemIndex] = updated;
                      ref
                          .read(orderProvider.notifier)
                          .updateItems(updatedItems);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
