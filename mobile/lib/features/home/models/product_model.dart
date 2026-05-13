class ProductModel {
  final String id;
  final String name;
  final String merchantName;
  final double originalPrice;
  final double discountPrice;
  final int stock;
  final String category;
  final double distanceKm;
  final String? imageUrl;
  final String? description;
  final String? pickupTimeStart;
  final String? pickupTimeEnd;

  const ProductModel({
    required this.id,
    required this.name,
    required this.merchantName,
    required this.originalPrice,
    required this.discountPrice,
    required this.stock,
    required this.category,
    required this.distanceKm,
    this.imageUrl,
    this.description,
    this.pickupTimeStart,
    this.pickupTimeEnd,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'],
      merchantName: json['merchant_name'] ?? '',
      originalPrice: (json['original_price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
      pickupTimeStart: (json['pickup_time_start'] as String?)?.substring(0, 5),
      pickupTimeEnd: (json['pickup_time_end'] as String?)?.substring(0, 5),
    );
  }

  int get discountPercent =>
      ((1 - discountPrice / originalPrice) * 100).round();
}
