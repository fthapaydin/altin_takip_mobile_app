import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';

class AssetDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const AssetDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('tr', 'TR'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.gold, // Header background & selection
                  onPrimary: Colors.black, // Header text & selection text
                  surface: Color(0xFF1E1E1E), // Background
                  onSurface: Colors.white, // Body text
                ),
                dialogBackgroundColor: const Color(0xFF1E1E1E),
                datePickerTheme: DatePickerThemeData(
                  headerBackgroundColor: const Color(0xFF1E1E1E),
                  headerForegroundColor: AppTheme.gold,
                  backgroundColor: const Color(0xFF1E1E1E),
                  surfaceTintColor: Colors.transparent,
                  dividerColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  headerHeadlineStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.gold,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) onDateChanged(date);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar_1,
              size: 20,
              color: AppTheme.gold.withValues(alpha: 0.7),
            ),
            const Gap(12),
            Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Icon(
              Iconsax.arrow_down_1,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
