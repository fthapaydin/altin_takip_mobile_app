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
                  surface: AppTheme.surface, // Background
                  onSurface: Colors.white, // Body text
                ),
                dialogBackgroundColor: AppTheme.surface,
                datePickerTheme: DatePickerThemeData(
                  headerBackgroundColor: AppTheme.surface,
                  headerForegroundColor: AppTheme.gold,
                  backgroundColor: AppTheme.surface,
                  surfaceTintColor: Colors.transparent,
                  dividerColor: Colors.white.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'İşlem Gerçekleşme Tarihi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.calendar_1,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
