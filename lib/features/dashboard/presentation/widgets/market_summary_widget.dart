import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/features/currencies/domain/currency.dart';

class MarketSummaryWidget extends StatelessWidget {
  final List<Currency> currencies;
  final Function(Currency, bool) onNavigateToHistory;

  const MarketSummaryWidget({
    super.key,
    required this.currencies,
    required this.onNavigateToHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (currencies.isEmpty) {
      return const _EmptyMarketWidget();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          return _MarketGridItem(
            currency: currency,
            onTap: () => onNavigateToHistory(currency, currency.isGold),
          );
        },
      ),
    );
  }
}

class _MarketGridItem extends StatelessWidget {
  final Currency currency;
  final VoidCallback onTap;

  const _MarketGridItem({
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spread = currency.selling - currency.buying;
    final isGold = currency.isGold;

    return Container(
      decoration: BoxDecoration(
        gradient: isGold
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF231C10), // Rich dark gold tone
                  Color(0xFF131416),
                ],
              )
            : AppTheme.luxuryGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGold ? AppTheme.gold.withOpacity(0.2) : AppTheme.glassBorder,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(context),
                _buildPriceSection(context),
                _buildSpreadSection(context, spread),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      currency.isGold ? currency.name : currency.code,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Text(
      '₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.selling)}',
      style: const TextStyle(
        fontFeatures: [FontFeature.tabularFigures()],
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 17,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSpreadSection(BuildContext context, double spread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alış:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '₺${NumberFormat('#,##0.00', 'tr_TR').format(currency.buying)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const Gap(3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Makas:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '₺${NumberFormat('#,##0.00', 'tr_TR').format(spread)}',
              style: TextStyle(
                color: currency.isGold ? AppTheme.gold.withOpacity(0.7) : Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyMarketWidget extends StatelessWidget {
  const _EmptyMarketWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: const Center(
        child: Text(
          'Piyasalar Takipte...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
