import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';

/// Shimmer loading skeleton for the Goal Detail screen.
class GoalDetailShimmer extends StatelessWidget {
  const GoalDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            const _ShimmerRing(),
            const Gap(20),
            const _ShimmerGoalInfoCard(),
            const Gap(28),
            const _ShimmerRemainingCard(),
            const Gap(28),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Gap(12),
            const _ShimmerInsights(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerRing extends StatelessWidget {
  const _ShimmerRing();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ShimmerGoalInfoCard extends StatelessWidget {
  const _ShimmerGoalInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(width: 40, height: 8, color: Colors.white),
                    const Gap(8),
                    Container(width: 80, height: 18, color: Colors.white),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white),
              Expanded(
                child: Column(
                  children: [
                    Container(width: 40, height: 8, color: Colors.white),
                    const Gap(8),
                    Container(width: 80, height: 18, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const Gap(24),
          Container(height: 1, color: Colors.white),
          const Gap(24),
          const Row(
            children: [
              Expanded(child: _ShimmerGridCell()),
              Expanded(child: _ShimmerGridCell()),
            ],
          ),
          const Gap(24),
          Container(height: 1, color: Colors.white),
          const Gap(24),
          const Row(
            children: [
              Expanded(child: _ShimmerGridCell()),
              Expanded(child: _ShimmerGridCell()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerGridCell extends StatelessWidget {
  const _ShimmerGridCell();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: Colors.white),
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 8, color: Colors.white),
            const Gap(6),
            Container(width: 60, height: 14, color: Colors.white),
          ],
        ),
      ],
    );
  }
}

class _ShimmerRemainingCard extends StatelessWidget {
  const _ShimmerRemainingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 60, height: 8, color: Colors.white),
              const Gap(6),
              Container(width: 100, height: 18, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerInsights extends StatelessWidget {
  const _ShimmerInsights();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: _ShimmerInsightCell()),
            Gap(10),
            Expanded(child: _ShimmerInsightCell()),
          ],
        ),
        const Gap(10),
        const _ShimmerInsightCell(isFullWidth: true),
        const Gap(16),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 250, height: 10, color: Colors.white),
              const Gap(4),
              Container(width: 200, height: 10, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShimmerInsightCell extends StatelessWidget {
  final bool isFullWidth;

  const _ShimmerInsightCell({this.isFullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 50, height: 8, color: Colors.white),
                const Gap(6),
                Container(width: 80, height: 14, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
