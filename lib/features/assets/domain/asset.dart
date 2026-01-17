import 'package:equatable/equatable.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

class Asset extends Equatable {
  final int id;
  final int currencyId;
  final String type; // buy or sell
  final double amount;
  final double price;
  final DateTime date;
  final String? place;
  final String? note;
  final String? encryptedOwnerId;
  final Currency? currency;

  const Asset({
    required this.id,
    required this.currencyId,
    required this.type,
    required this.amount,
    required this.price,
    required this.date,
    this.place,
    this.note,
    this.encryptedOwnerId,
    this.currency,
  });

  @override
  List<Object?> get props => [
    id,
    currencyId,
    type,
    amount,
    price,
    date,
    place,
    note,
    encryptedOwnerId,
    currency,
  ];
}
