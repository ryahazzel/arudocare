class ProductModel {
  final String id;
  final String name;
  final String merchantName;
  final int merchantId;
  final double originalPrice;
  final double discountPrice;
  final int stock;
  final String category;
  final double distanceKm;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? description;
  final String? pickupTimeStart;
  final String? pickupTimeEnd;

  const ProductModel({
    required this.id,
    required this.name,
    required this.merchantName,
    required this.merchantId,
    required this.originalPrice,
    required this.discountPrice,
    required this.stock,
    required this.category,
    required this.distanceKm,
    this.latitude,
    this.longitude,
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
      merchantId: int.tryParse(json['merchant_id']?.toString() ?? '') ?? 0,
      originalPrice: double.parse(json['original_price'].toString()),
      discountPrice: double.parse(json['discount_price'].toString()),
      stock: int.parse(json['stock'].toString()),
      category: json['category'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      latitude: json['latitude'] == null ? null : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] == null ? null : double.tryParse(json['longitude'].toString()),
      imageUrl: json['image_url'],
      description: json['description'],
      pickupTimeStart: _safeSubstring(json['pickup_time_start'] as String?),
      pickupTimeEnd: _safeSubstring(json['pickup_time_end'] as String?),
    );
  }

  int get discountPercent =>
      ((1 - discountPrice / originalPrice) * 100).round();
}

String? _safeSubstring(String? value) {
  if (value == null || value.length < 5) return value;
  return value.substring(0, 5);
}
