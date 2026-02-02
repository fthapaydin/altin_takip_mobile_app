import 'package:flutter/material.dart';

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
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Minimal Sliding Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuad,
            alignment: isBuy ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Text Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: isBuy
                            ? const Color(0xFF4ADE80) // Green
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                      child: const Text('Alım'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTypeChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: !isBuy
                            ? const Color(0xFFF87171) // Red
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                      child: const Text('Satım'),
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
