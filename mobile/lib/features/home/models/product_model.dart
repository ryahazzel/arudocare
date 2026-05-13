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
    );
  }

  int get discountPercent =>
      ((1 - discountPrice / originalPrice) * 100).round();
}
