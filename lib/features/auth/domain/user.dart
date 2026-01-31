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

  String _toTitleCase(String text) {
    if (text.trim().isEmpty) return '';
    return text
        .trim()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String get formattedName => _toTitleCase(name);

  String get formattedSurname => _toTitleCase(surname);

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
