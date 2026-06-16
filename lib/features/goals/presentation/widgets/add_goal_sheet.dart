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
      decoration: BoxDecoration(
        color: const Color(0xFF0F1116),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yeni Hedef',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
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
            _GradientButton(
              onTap: _submit,
              text: 'Hedef Oluştur',
              isLoading: _isLoading,
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
        fontWeight: FontWeight.w500,
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: AppTheme.gold, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.gold, width: 1.2),
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
                      : Colors.white.withValues(alpha: 0.02),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar_1,
              color: Colors.white.withValues(alpha: 0.4),
              size: 16,
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
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (_targetDate != null)
              GestureDetector(
                onTap: () => setState(() => _targetDate = null),
                child: Icon(
                  Iconsax.close_circle,
                  size: 16,
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
                      : Colors.white.withValues(alpha: 0.02),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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

// ── Shared Sub Widget ──

class _GradientButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isLoading;

  const _GradientButton({
    required this.onTap,
    required this.text,
    required this.isLoading,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;
    final isEnabled = widget.onTap != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      onTap: isEnabled ? widget.onTap : null,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? AppTheme.goldGradient
                : LinearGradient(
                    colors: [
                      AppTheme.gold.withValues(alpha: 0.3),
                      AppTheme.gold.withValues(alpha: 0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
