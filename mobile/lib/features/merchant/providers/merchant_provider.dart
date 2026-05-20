import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class MerchantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = false;
  bool _isInventoryLoading = false;
  bool _isSubmitting = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isInventoryLoading => _isInventoryLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get inventory => _inventory;

  List<Map<String, dynamic>> get pendingOrders =>
      _orders.where((o) => o['status'] == 'pending').toList();

  double get todayRevenue {
    final today = DateTime.now();
    return _orders
        .where((o) {
          final raw = o['created_at'] as String?;
          if (raw == null) return false;
          final dt = DateTime.tryParse(raw)?.toLocal();
          return dt != null &&
              dt.year == today.year &&
              dt.month == today.month &&
              dt.day == today.day;
        })
        .fold(0.0, (sum, o) => sum + ((o['total_price'] as num?)?.toDouble() ?? 0));
  }

  int get portionsSaved => _orders
      .where((o) => o['status'] == 'completed')
      .fold(0, (sum, o) => sum + ((o['quantity'] as int?) ?? 0));

  Future<void> fetchOrders(int merchantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/orders/merchant/$merchantId');
      if (response.statusCode == 200) {
        _orders = List<Map<String, dynamic>>.from(response.data as List);
      }
    } on DioException {
      // Pertahankan data yang ada jika API tidak tersedia
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchInventory(int merchantId) async {
    _isInventoryLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/products/merchant/$merchantId');
      if (response.statusCode == 200) {
        _inventory = List<Map<String, dynamic>>.from(response.data as List);
      }
    } on DioException {
      // Keep existing data if API unavailable
    }

    _isInventoryLoading = false;
    notifyListeners();
  }

  Future<void> toggleProduct(int productId) async {
    final index = _inventory.indexWhere((p) => (p['id'] as num?)?.toInt() == productId);
    if (index == -1) return;

    final current = _inventory[index]['is_active'] as bool? ?? true;
    _inventory[index] = {..._inventory[index], 'is_active': !current};
    notifyListeners();

    try {
      await _apiClient.dio.patch('/products/$productId/toggle');
    } on DioException {
      _inventory[index] = {..._inventory[index], 'is_active': current};
      notifyListeners();
    }
  }

  Future<bool> addProduct({
    required int merchantId,
    required String merchantName,
    required String name,
    required String description,
    required double originalPrice,
    required double discountPrice,
    required int stock,
    required int categoryId,
    required String pickupTimeStart,
    required String pickupTimeEnd,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/products', data: {
        'merchant_id': merchantId,
        'merchant_name': merchantName,
        'name': name,
        'description': description,
        'original_price': originalPrice,
        'discount_price': discountPrice,
        'stock': stock,
        'category_id': categoryId,
        'pickup_time_start': pickupTimeStart,
        'pickup_time_end': pickupTimeEnd,
      });

      _isSubmitting = false;
      notifyListeners();
      return response.statusCode == 201;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal menambah produk';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
