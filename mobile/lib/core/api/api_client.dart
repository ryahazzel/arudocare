import 'package:dio/dio.dart';

class ApiClient {
  // USB physical device: requires `adb reverse tcp:8000 tcp:8000` before running
  // Android emulator: ganti ke 'http://10.0.2.2:8000/api'
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