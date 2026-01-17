import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String? oneSignalId;

  final bool isEncrypted;

  const User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.isEncrypted,
    this.oneSignalId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    surname,
    email,
    oneSignalId,
    isEncrypted,
  ];
}
