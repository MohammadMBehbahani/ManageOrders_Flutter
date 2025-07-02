class ShopDetails {
  final String shopName;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String postcode;
  final String phone;

  ShopDetails({
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.postcode,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'address4': address4,
      'postcode': postcode,
      'phone': phone,
    };
  }

  static ShopDetails fromMap(Map<String, dynamic> map) {
    return ShopDetails(
      shopName: map['shopName'],
      address1: map['address1'],
      address2: map['address2'],
      address3: map['address3'],
      address4: map['address4'],
      postcode: map['postcode'],
      phone: map['phone'],
    );
  }
}
