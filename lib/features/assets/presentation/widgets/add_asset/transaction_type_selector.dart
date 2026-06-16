import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

class TransactionTypeSelector extends StatelessWidget {
  final bool isBuy;
  final ValueChanged<bool> onTypeChanged;

  const TransactionTypeSelector({
    key,
    required this.isBuy,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeColor = isBuy
        ? const Color(0xFF10B981) // Emerald green
        : const Color(0xFFEF4444); // Rose red

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        children: [
          // Sliding Selector Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: isBuy ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBuy
                        ? [
                            const Color(0xFF10B981).withValues(alpha: 0.18),
                            const Color(0xFF10B981).withValues(alpha: 0.06),
                          ]
                        : [
                            const Color(0xFFEF4444).withValues(alpha: 0.18),
                            const Color(0xFFEF4444).withValues(alpha: 0.06),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Clickable options
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.add_circle5,
                          size: 16,
                          color: isBuy
                              ? const Color(0xFF10B981)
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        const Gap(8),
                        Text(
                          'Alım',
                          style: TextStyle(
                            color: isBuy
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            fontWeight: isBuy ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.minus_cirlce5,
                          size: 16,
                          color: !isBuy
                              ? const Color(0xFFEF4444)
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        const Gap(8),
                        Text(
                          'Satım',
                          style: TextStyle(
                            color: !isBuy
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            fontWeight: !isBuy ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
