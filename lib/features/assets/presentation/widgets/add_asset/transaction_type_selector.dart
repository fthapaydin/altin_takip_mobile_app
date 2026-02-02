import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

class TransactionTypeSelector extends StatelessWidget {
  final bool isBuy;
  final ValueChanged<bool> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.isBuy,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Buy Option
        Expanded(
          child: GestureDetector(
            onTap: () => onTypeChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isBuy
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isBuy
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.add_circle5,
                    size: 16,
                    color: isBuy ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                  const Gap(6),
                  Text(
                    'Alım',
                    style: TextStyle(
                      color: isBuy
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(10),
        // Sell Option
        Expanded(
          child: GestureDetector(
            onTap: () => onTypeChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !isBuy
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !isBuy
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.minus_cirlce5,
                    size: 16,
                    color: !isBuy
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                  const Gap(6),
                  Text(
                    'Satım',
                    style: TextStyle(
                      color: !isBuy
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
