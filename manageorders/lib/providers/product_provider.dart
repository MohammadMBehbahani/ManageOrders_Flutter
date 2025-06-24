import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/product_database.dart';
import 'package:manageorders/models/product.dart';
import 'package:manageorders/models/sub_product_option.dart';
import 'package:uuid/uuid.dart';

final productProvider =
    AsyncNotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return await ProductDatabase.getAllProducts();
  }

  Future<void> addProduct(Product product) async {
    final newProduct = product.id.isEmpty
        ? product.copyWith(id: const Uuid().v4())
        : product;

    await ProductDatabase.insertProduct(newProduct);
    state = AsyncData([...state.value ?? [], newProduct]);
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await ProductDatabase.updateProduct(updatedProduct);
    state = AsyncData([
      for (final p in state.value ?? [])
        if (p.id == updatedProduct.id) updatedProduct else p,
    ]);
  }

  Future<void> deleteProduct(String id) async {
    await ProductDatabase.deleteProduct(id);
    state = AsyncData((state.value ?? []).where((p) => p.id != id).toList());
  }

  Future<void> addSubProductOptions(
      String productId, List<SubProductOption> newOptions) async {
    final currentProducts = state.value ?? [];
    final productIndex =
        currentProducts.indexWhere((p) => p.id == productId);
    if (productIndex == -1) return;

    final product = currentProducts[productIndex];
    final mergedOptions = [
      ...product.availableSubProducts,
      ...newOptions.where(
          (newOpt) => !product.availableSubProducts.any((opt) => opt.id == newOpt.id))
    ];

    final updatedProduct = product.copyWith(availableSubProducts: mergedOptions);
    await updateProduct(updatedProduct);
  }

  Future<List<Product>> getProductsForCategory(String categoryId) async {
    return await ProductDatabase.getProductsByCategoryId(categoryId);
  }

}

  