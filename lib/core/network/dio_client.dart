import 'package:dio/dio.dart';
import 'package:altin_takip/core/storage/storage_service.dart';

class DioClient {
  final StorageService _storageService;
  late final Dio dio;

  DioClient(this._storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://altin.kiracilarim.com/api/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final encryptionKey = await _storageService.getEncryptionKey();
          if (encryptionKey != null) {
            options.headers['X-Encryption-Key'] = encryptionKey;
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors like 401
          if (e.response?.statusCode == 401) {
            // Logout user or refresh token
          }
          return handler.next(e);
        },
      ),
    );
  }
}
