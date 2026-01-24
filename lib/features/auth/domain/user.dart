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

  bool get isEncrypted;

  String get formattedName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  String get formattedSurname => surname.toUpperCase();

  String get fullName => '$formattedName $formattedSurname';

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
