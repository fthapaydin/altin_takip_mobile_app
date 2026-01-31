import 'package:intl/intl.dart';
import 'package:altin_takip/features/currencies/domain/currency_history.dart';

class CurrencyHistoryDto extends CurrencyHistory {
  const CurrencyHistoryDto({
    required super.buying,
    required super.selling,
    required super.date,
  });

  factory CurrencyHistoryDto.fromJson(Map<String, dynamic> json) {
    // Expected format: "24.01.2026 15:00" or "dd.MM.yyyy"
    final dateStr = json['created_at'] as String;
    DateTime date;
    try {
      if (dateStr.length > 10) {
        date = DateFormat('dd.MM.yyyy HH:mm').parse(dateStr);
      } else {
        date = DateFormat('dd.MM.yyyy').parse(dateStr);
      }
    } catch (e) {
      print('DEBUG: Date parsing failed for $dateStr: $e');
      rethrow;
    }

    return CurrencyHistoryDto(
      buying: (json['buying'] as num).toDouble(),
      selling: (json['selling'] as num).toDouble(),
      date: date,
    );
  }
}
