import 'package:dio/dio.dart';

class ApiClient {
  // WiFi (HP + PC 1 jaringan): pakai IP PC di bawah ini
  // Android emulator: ganti ke 'http://10.0.2.2:8000/api'
  // USB ADB reverse: ganti ke 'http://localhost:8000/api' + jalankan `adb reverse tcp:8000 tcp:8000`
  static const String baseUrl = 'http://localhost:8000/api';

  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
}