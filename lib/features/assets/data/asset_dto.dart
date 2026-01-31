import 'package:altin_takip/features/assets/domain/asset.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

class CurrencyDto extends Currency {
  const CurrencyDto({
    required super.id,
    required super.code,
    required super.name,
    required super.type,
    required super.buying,
    required super.selling,
    required super.lastUpdatedAt,
    super.iconUrl,
  });

  factory CurrencyDto.fromJson(Map<String, dynamic> json) {
    return CurrencyDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      code: json['code'],
      name: json['name'],
      type: json['type'],
      buying: double.parse(json['buying'].toString()),
      selling: double.parse(json['selling'].toString()),
      lastUpdatedAt: DateTime.parse(json['last_updated_at']),
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'buying': buying,
      'selling': selling,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
    };
  }
}

class AssetDto extends Asset {
  const AssetDto({
    required super.id,
    required super.currencyId,
    required super.type,
    required super.amount,
    required super.price,
    required super.date,
    super.place,
    super.note,
    super.encryptedOwnerId,
    super.currency,
  });

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return AssetDto(
      id: json['id'],
      currencyId: json['currency_id'] is int
          ? json['currency_id']
          : int.parse(json['currency_id'].toString()),
      type: json['type'],
      amount: double.parse(json['amount'].toString()),
      price: double.parse(json['price'].toString()),
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.parse(json['date']),
      place: json['place'],
      note: json['note'],
      encryptedOwnerId: json['encrypted_owner_id'],
      currency: json['currency'] != null
          ? CurrencyDto.fromJson(json['currency'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency_id': currencyId,
      'type': type,
      'amount': amount,
      'price': price,
      'date': date.toIso8601String(),
      'place': place,
      'note': note,
      'encrypted_owner_id': encryptedOwnerId,
    };
  }
}
