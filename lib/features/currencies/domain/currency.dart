import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final int id;
  final String code;
  final String name;
  final String type;
  final double buying;
  final double selling;
  final DateTime lastUpdatedAt;
  final String? iconUrl;

  const Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.buying,
    required this.selling,
    required this.lastUpdatedAt,
    this.iconUrl,
  });

  bool get isGold => type.toLowerCase() == 'altın';

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    type,
    buying,
    selling,
    lastUpdatedAt,
    iconUrl,
  ];
}
