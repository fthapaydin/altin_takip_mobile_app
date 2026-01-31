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
      final apiMessage = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? data['message']?.toString())
          : null;

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
                : 'Girdiğiniz bilgeri kontrol edin.';
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
}
