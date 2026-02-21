import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/widgets/app_notification.dart';
import 'package:altin_takip/core/utils/currency_input_formatter.dart';
import 'package:altin_takip/features/goals/domain/goal.dart';
import 'package:altin_takip/features/goals/presentation/goal_notifier.dart';
import 'package:iconsax/iconsax.dart';

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddGoalSheet(),
    );
  }

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  GoalCategory _category = GoalCategory.gold;
  GoalPriority _priority = GoalPriority.medium;
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final amount = double.tryParse(amountText);

    if (name.isEmpty) {
      AppNotification.show(
        context,
        message: 'Hedef adı giriniz.',
        type: NotificationType.error,
      );
      return;
    }
    if (amount == null || amount <= 0) {
      AppNotification.show(
        context,
        message: 'Geçerli bir hedef tutar giriniz.',
        type: NotificationType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(goalProvider.notifier)
        .createGoal(
          name: name,
          category: _category,
          targetAmount: amount,
          targetDate: _targetDate,
          priority: _priority,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      AppNotification.show(
        context,
        message: 'Hedef başarıyla oluşturuldu!',
        type: NotificationType.success,
      );
    } else {
      AppNotification.show(
        context,
        message: 'Hedef oluşturulamadı.',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(20),
            const Center(
              child: Text(
                'Yeni Hedef',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Gap(28),
            // Name
            _buildLabel('HEDEF ADI'),
            const Gap(8),
            _buildTextField(controller: _nameController, hint: 'Ör: Ev Almak'),
            const Gap(20),
            // Category
            _buildLabel('KATEGORİ'),
            const Gap(8),
            _buildCategorySelector(),
            const Gap(20),
            // Amount
            _buildLabel('HEDEF TUTAR'),
            const Gap(8),
            _buildTextField(
              controller: _amountController,
              hint: '0',
              prefix: '₺',
              keyboardType: TextInputType.number,
              formatters: [TurkishCurrencyFormatter()],
            ),
            const Gap(20),
            // Date (optional)
            _buildLabel('HEDEF TARİH (OPSİYONEL)'),
            const Gap(8),
            _buildDatePicker(),
            const Gap(20),
            // Priority
            _buildLabel('ÖNCELİK'),
            const Gap(8),
            _buildPrioritySelector(),
            const Gap(32),
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: AppTheme.gold.withValues(alpha: 0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Hedef Oluştur',
                        style: TextStyle(fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.gold.withValues(alpha: 0.8),
        fontSize: 10,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: AppTheme.gold, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: GoalCategory.values.map((cat) {
        final isSelected = _category == cat;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: cat != GoalCategory.all ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.gold.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Center(
                  child: Text(
                    cat.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.gold
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar_1,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
            ),
            const Gap(12),
            Text(
              _targetDate != null
                  ? DateFormat('d MMMM yyyy', 'tr_TR').format(_targetDate!)
                  : 'Tarih seç',
              style: TextStyle(
                color: _targetDate != null
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (_targetDate != null)
              GestureDetector(
                onTap: () => setState(() => _targetDate = null),
                child: Icon(
                  Iconsax.close_circle,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: GoalPriority.values.map((p) {
        final isSelected = _priority == p;
        final color = switch (p) {
          GoalPriority.high => Colors.red,
          GoalPriority.medium => Colors.amber,
          GoalPriority.low => const Color(0xFF34D399),
        };

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p != GoalPriority.low ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _priority = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.1)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        p.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
