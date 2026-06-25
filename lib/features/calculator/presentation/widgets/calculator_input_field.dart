import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

/// Customized numeric input field used across calculation screens.
class CalculatorInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefix;
  final String? suffix;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;

  const CalculatorInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
    this.suffix,
    this.formatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppTheme.gold.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
        const Gap(10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ...?formatters,
          ],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
              fontSize: 13,
            ),
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppTheme.gold,
                width: 1.2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
