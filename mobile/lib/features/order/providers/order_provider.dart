import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../home/models/product_model.dart';

class OrderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _lastOrder;
  List<Map<String, dynamic>> _orders = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get lastOrder => _lastOrder;

  List<Map<String, dynamic>> get activeOrders =>
      _orders.where((o) => o['status'] == 'pending').toList();

  List<Map<String, dynamic>> get completedOrders =>
      _orders.where((o) => o['status'] == 'completed').toList();

  Future<bool> createOrder({
    required int userId,
    required ProductModel product,
    required int quantity,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final totalPrice = product.discountPrice * quantity;

    try {
      final response = await _apiClient.dio.post('/orders', data: {
        'user_id': userId,
        'product_id': int.parse(product.id),
        'merchant_id': product.merchantId,
        'product_name': product.name,
        'merchant_name': product.merchantName,
        'quantity': quantity,
        'total_price': totalPrice,
      });

      if (response.statusCode == 201) {
        _lastOrder = response.data['order'] as Map<String, dynamic>;
        _orders.insert(0, _lastOrder!);

        try {
          await _apiClient.dio.put(
            '/products/${product.id}/stock',
            data: {'quantity': quantity},
          );
        } catch (_) {}

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException {
      _lastOrder = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'qr_code': 'DEMO-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'product_name': product.name,
        'merchant_name': product.merchantName,
        'quantity': quantity,
        'total_price': totalPrice,
        'created_at': DateTime.now().toIso8601String(),
      };
      _orders.insert(0, _lastOrder!);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _error = 'Gagal membuat pesanan. Coba lagi.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchUserOrders(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/orders/user/$userId');
      if (response.statusCode == 200) {
        _orders = List<Map<String, dynamic>>.from(response.data as List);
      }
    } on DioException {
      // Pertahankan _orders yang ada (termasuk demo order dari session ini)
    }

    _isLoading = false;
    notifyListeners();
  }
}
