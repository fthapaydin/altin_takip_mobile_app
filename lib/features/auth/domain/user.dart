import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? oneSignalId;
  final bool isEncrypted;

  const User({
    required this.id,
    required this.email,
    required this.isEncrypted,
    this.oneSignalId,
  });

  @override
  List<Object?> get props => [id, email, oneSignalId, isEncrypted];
}
