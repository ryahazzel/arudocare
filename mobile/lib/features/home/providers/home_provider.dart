import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/api/api_client.dart';
import '../models/product_model.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<ProductModel> _nearbyDeals = [];
  bool _isLoading = false;
  String? _error;
  LatLng? _userLocation;

  List<ProductModel> get nearbyDeals => _nearbyDeals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LatLng? get userLocation => _userLocation;

  Future<void> fetchNearbyDeals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final position = await _tryGetLocation();
    if (position != null) {
      _userLocation = LatLng(position.latitude, position.longitude);
    }

    try {
      final queryParams = position != null
          ? {'lat': position.latitude, 'lng': position.longitude}
          : <String, dynamic>{};

      final response = await _apiClient.dio.get('/products', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List data = response.data as List;
        _nearbyDeals = data.map((e) => ProductModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Gagal memuat produk';
    } catch (_) {
      _error = 'Gagal memuat produk';
    }

    _isLoading = false;
    notifyListeners();
  }
}

Future<Position?> _tryGetLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  } catch (_) {
    return null;
  }
}
