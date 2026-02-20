import 'package:dio/dio.dart';

class NetworkExceptionHandler {
  static String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        case DioExceptionType.cancel:
          return 'İşlem iptal edildi.';
        case DioExceptionType.connectionError:
          return 'İnternet bağlantısı yok veya sunucuya erişilemiyor.';
        default:
          return 'Beklenmedik bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
      }
    } else if (error is FormatException) {
      return 'Veri formatı hatası. Uygulama güncel olmayabilir.';
    } else {
      return 'Bir hata oluştu: $error';
    }
  }

  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final dynamic data = error.response?.data;

    try {
      final apiMessage = _extractMessage(data);

      if (statusCode == 401) {
        return apiMessage ?? 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
      } else if (statusCode == 403) {
        return apiMessage ?? 'Bu işlem için yetkiniz yok.';
      } else if (statusCode == 404) {
        return apiMessage ?? 'İstenen kaynak bulunamadı.';
      } else if (statusCode == 422) {
        // Handle Laravel validation errors
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            final messages = errors.values
                .expand((element) {
                  if (element is List) return element;
                  return [element];
                })
                .join('\n');
            return messages.isNotEmpty
                ? messages
                : 'Girdiğiniz bilgileri kontrol edin.';
          }
        }
        return apiMessage ?? 'Lütfen girdiğiniz bilgileri kontrol edin.';
      } else if (statusCode == 429) {
        return apiMessage ??
            'Çok fazla istek gönderdiniz. Lütfen biraz bekleyin.';
      } else if (statusCode != null && statusCode >= 500) {
        return apiMessage ??
            'Sunucu kaynaklı bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
      }

      return apiMessage ?? 'Bir hata oluştu ($statusCode)';
    } catch (_) {
      return 'Beklenmedik bir sunucu hatası oluştu.';
    }
  }

  /// Extracts error message from various API response formats.
  ///
  /// Supports: { "message": "..." }, { "error": "..." },
  /// { "msg": "..." }, { "detail": "..." },
  /// { "data": { "message": "..." } }, plain string responses, etc.
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;

    // Plain string response
    if (data is String && data.isNotEmpty) return data;

    // Map response — try common keys
    if (data is Map<String, dynamic>) {
      // Direct keys (priority order)
      final directKeys = ['message', 'error', 'msg', 'detail', 'reason'];
      for (final key in directKeys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }

      // Nested: { "data": { "message": "..." } }
      if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'] as Map<String, dynamic>;
        for (final key in directKeys) {
          final value = nested[key];
          if (value is String && value.isNotEmpty) return value;
        }
      }

      // Try first string value in the map as last resort
      for (final value in data.values) {
        if (value is String && value.isNotEmpty && value.length < 200) {
          return value;
        }
      }
    }

    return null;
  }
}
