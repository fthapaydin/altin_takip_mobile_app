import 'package:altin_takip/features/auth/domain/user.dart';

class UserDto extends User {
  const UserDto({
    required super.id,
    required super.email,
    required super.isEncrypted,
    super.oneSignalId,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['user_id'] ?? json['id'],
      email: json['email'],
      isEncrypted: json['encrypted'] ?? false,
      oneSignalId: json['onesignal_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'encrypted': isEncrypted,
      'onesignal_id': oneSignalId,
    };
  }
}
