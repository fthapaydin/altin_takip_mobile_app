import 'package:dio/dio.dart';

/// Dio client for public API calls (no authentication required)
class PublicDioClient {
  late final Dio dio;

  PublicDioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://finans.truncgil.com/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
