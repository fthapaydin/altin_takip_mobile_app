sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Sunucu hatası oluştu.'])
    : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Kimlik doğrulama hatası.'])
    : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Önbellek hatası.']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'İnternet bağlantısı yok.'])
    : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class EncryptionRequiredFailure extends Failure {
  const EncryptionRequiredFailure([String message = 'Şifreleme anahtarı gerekli.']) : super(message);
}
