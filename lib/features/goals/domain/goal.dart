import 'package:equatable/equatable.dart';

// ── Enums ──

enum GoalCategory {
  gold,
  currency,
  all;

  String get displayName {
    switch (this) {
      case GoalCategory.gold:
        return 'Altın';
      case GoalCategory.currency:
        return 'Döviz';
      case GoalCategory.all:
        return 'Tümü';
    }
  }

  String get apiValue {
    switch (this) {
      case GoalCategory.gold:
        return 'gold';
      case GoalCategory.currency:
        return 'currency';
      case GoalCategory.all:
        return 'all';
    }
  }

  static GoalCategory fromString(String value) {
    switch (value) {
      case 'gold':
        return GoalCategory.gold;
      case 'currency':
        return GoalCategory.currency;
      case 'all':
        return GoalCategory.all;
      default:
        return GoalCategory.all;
    }
  }
}

enum GoalPriority {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case GoalPriority.high:
        return 'Yüksek';
      case GoalPriority.medium:
        return 'Orta';
      case GoalPriority.low:
        return 'Düşük';
    }
  }

  String get apiValue {
    switch (this) {
      case GoalPriority.high:
        return 'high';
      case GoalPriority.medium:
        return 'medium';
      case GoalPriority.low:
        return 'low';
    }
  }

  static GoalPriority fromString(String value) {
    switch (value) {
      case 'high':
        return GoalPriority.high;
      case 'medium':
        return GoalPriority.medium;
      case 'low':
        return GoalPriority.low;
      default:
        return GoalPriority.medium;
    }
  }
}

enum GoalStatus {
  active,
  completed,
  paused,
  cancelled;

  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Aktif';
      case GoalStatus.completed:
        return 'Tamamlandı';
      case GoalStatus.paused:
        return 'Duraklatıldı';
      case GoalStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  String get apiValue {
    switch (this) {
      case GoalStatus.active:
        return 'active';
      case GoalStatus.completed:
        return 'completed';
      case GoalStatus.paused:
        return 'paused';
      case GoalStatus.cancelled:
        return 'cancelled';
    }
  }

  static GoalStatus fromString(String value) {
    switch (value) {
      case 'active':
        return GoalStatus.active;
      case 'completed':
        return GoalStatus.completed;
      case 'paused':
        return GoalStatus.paused;
      case 'cancelled':
        return GoalStatus.cancelled;
      default:
        return GoalStatus.active;
    }
  }
}

// ── Value Objects ──

class GoalProgress extends Equatable {
  final double currentValue;
  final double targetAmount;
  final double remainingAmount;
  final double progressPercentage;

  const GoalProgress({
    required this.currentValue,
    required this.targetAmount,
    required this.remainingAmount,
    required this.progressPercentage,
  });

  /// Capped at 1.0 for UI progress bars
  double get normalizedProgress => (progressPercentage / 100).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
    currentValue,
    targetAmount,
    remainingAmount,
    progressPercentage,
  ];
}

class GoalInsights extends Equatable {
  final double? monthlyRequired;
  final int? remainingMonths;
  final int? estimatedCompletionMonths;
  final String message;

  const GoalInsights({
    required this.monthlyRequired,
    required this.remainingMonths,
    required this.estimatedCompletionMonths,
    required this.message,
  });

  @override
  List<Object?> get props => [
    monthlyRequired,
    remainingMonths,
    estimatedCompletionMonths,
    message,
  ];
}

// ── Entity ──

class Goal extends Equatable {
  final int id;
  final String name;
  final GoalCategory category;
  final double targetAmount;
  final DateTime? targetDate;
  final GoalPriority priority;
  final GoalStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GoalProgress? progress;
  final GoalInsights? insights;

  const Goal({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmount,
    this.targetDate,
    required this.priority,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.progress,
    this.insights,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    targetAmount,
    targetDate,
    priority,
    status,
    completedAt,
    createdAt,
    updatedAt,
    progress,
    insights,
  ];
}
