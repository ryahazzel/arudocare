import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/product_model.dart';

// Mock data used until Product Service (port 8002) is ready
const List<Map<String, dynamic>> _mockProducts = [
  {
    'id': '1',
    'name': 'Nasi Kotak Spesial',
    'merchant_name': 'Warung Bu Siti',
    'original_price': 35000,
    'discount_price': 15000,
    'stock': 5,
    'category': 'Makanan Siap Saji',
    'distance_km': 0.3,
  },
  {
    'id': '2',
    'name': 'Croissant Butter',
    'merchant_name': 'Roti Kita Bakery',
    'original_price': 28000,
    'discount_price': 12000,
    'stock': 8,
    'category': 'Bakery',
    'distance_km': 0.7,
  },
  {
    'id': '3',
    'name': 'Paket Sayur Mix',
    'merchant_name': 'Pasar Segar',
    'original_price': 20000,
    'discount_price': 9000,
    'stock': 12,
    'category': 'Sayuran',
    'distance_km': 1.2,
  },
  {
    'id': '4',
    'name': 'Bento Ayam Teriyaki',
    'merchant_name': 'Hana Kitchen',
    'original_price': 45000,
    'discount_price': 22000,
    'stock': 3,
    'category': 'Makanan Siap Saji',
    'distance_km': 1.5,
  },
  {
    'id': '5',
    'name': 'Roti Gandum Sourdough',
    'merchant_name': 'Artisan Bread Co.',
    'original_price': 55000,
    'discount_price': 25000,
    'stock': 4,
    'category': 'Bakery',
    'distance_km': 2.1,
  },
];

class HomeProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<ProductModel> _nearbyDeals = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get nearbyDeals => _nearbyDeals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNearbyDeals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/products');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        _nearbyDeals = data.map((e) => ProductModel.fromJson(e)).toList();
      }
    } on DioException {
      // Product service not yet available — fall back to mock data
      await Future.delayed(const Duration(milliseconds: 300));
      _nearbyDeals = _mockProducts.map(ProductModel.fromJson).toList();
    } catch (_) {
      _nearbyDeals = _mockProducts.map(ProductModel.fromJson).toList();
    }

    _isLoading = false;
    notifyListeners();
  }
}
