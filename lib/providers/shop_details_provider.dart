import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/shop_details_database.dart';
import 'package:manageorders/models/shop_details.dart';

final shopDetailsProvider =
    AsyncNotifierProvider<ShopDetailsNotifier, ShopDetails?>(
  ShopDetailsNotifier.new,
);

class ShopDetailsNotifier extends AsyncNotifier<ShopDetails?> {
  @override
  FutureOr<ShopDetails?> build() async {
    return await ShopDetailsDatabase.load(); // Now loads on first use
  }

  Future<void> saveShopDetails({
    required String shopName,
    required String address1,
    required String address2,
    required String address3,
    required String address4,
    required String postcode,
    required String phone,
  }) async {
    final details = ShopDetails(
      shopName: shopName,
      address1: address1,
      address2: address2,
      address3: address3,
      address4: address4,
      postcode: postcode,
      phone: phone,
    );

    await ShopDetailsDatabase.save(details);
    state = AsyncValue.data(details); // Update state
  }
}
