class ManageLeftView {
  final String id;
  final int? fontsizecategory;
  final int? fontsizeproduct;
  final int? boxwidthproduct;
  final int? boxheightcategory;
  final int? boxwidthcategory;
  final int? boxheightproduct;

  ManageLeftView({
    required this.id,
    this.fontsizecategory,
    this.fontsizeproduct,
    this.boxwidthproduct,
    this.boxheightcategory,
    this.boxwidthcategory,
    this.boxheightproduct,
  });

  factory ManageLeftView.fromJson(Map<String, dynamic> json) {
    return ManageLeftView(
      id: json['id'] ?? json['_id'],
      fontsizecategory: json['fontsizecategory'],
      fontsizeproduct: json['fontsizeproduct'],
      boxwidthproduct: json['boxwidthproduct'],
      boxheightcategory: json['boxheightcategory'],
      boxwidthcategory: json['boxwidthcategory'],
      boxheightproduct: json['boxheightproduct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fontsizecategory': fontsizecategory,
      'fontsizeproduct': fontsizeproduct,
      'boxwidthproduct': boxwidthproduct,
      'boxheightcategory': boxheightcategory,
      'boxwidthcategory': boxwidthcategory,
      'boxheightproduct': boxheightproduct,
    };
  }

  factory ManageLeftView.fromMap(Map<String, dynamic> map) => ManageLeftView.fromJson(map);
  Map<String, dynamic> toMap() => toJson();
}
