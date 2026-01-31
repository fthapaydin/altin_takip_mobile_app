import 'package:equatable/equatable.dart';

class CurrencyHistory extends Equatable {
  final double buying;
  final double selling;
  final DateTime date;

  const CurrencyHistory({
    required this.buying,
    required this.selling,
    required this.date,
  });

  @override
  List<Object?> get props => [buying, selling, date];
}
