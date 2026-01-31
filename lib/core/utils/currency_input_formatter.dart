import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TurkishCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // If only one character and it's a comma, make it "0,"
    if (newValue.text == ',') {
      return newValue.copyWith(
        text: '0,',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    // Clean text except digits and comma
    String cleanText = newValue.text.replaceAll('.', '');

    // Check if there are multiple commas
    int commaCount = cleanText.split(',').length - 1;
    if (commaCount > 1) {
      return oldValue;
    }

    List<String> parts = cleanText.split(',');
    String integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    String? decimalPart = parts.length > 1
        ? parts[1].replaceAll(RegExp(r'[^0-9]'), '')
        : null;

    if (integerPart.isEmpty && decimalPart == null) {
      return newValue.copyWith(text: '');
    }

    // Limit decimal part to 2 digits for currency
    if (decimalPart != null && decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // Format integer part with dots
    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      final formatter = NumberFormat('#,###', 'tr_TR');
      formattedInteger = formatter
          .format(int.parse(integerPart))
          .replaceAll(',', '.');
    } else if (decimalPart != null) {
      formattedInteger = '0';
    }

    String finalText = formattedInteger;
    if (cleanText.contains(',')) {
      finalText += ',${decimalPart ?? ''}';
    }

    return newValue.copyWith(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}
