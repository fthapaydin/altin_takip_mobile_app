import 'package:altin_takip/features/goals/domain/goal.dart';

class GoalProgressDto extends GoalProgress {
  const GoalProgressDto({
    required super.currentValue,
    required super.targetAmount,
    required super.remainingAmount,
    required super.progressPercentage,
  });

  factory GoalProgressDto.fromJson(Map<String, dynamic> json) {
    return GoalProgressDto(
      currentValue: double.parse(json['current_value'].toString()),
      targetAmount: double.parse(json['target_amount'].toString()),
      remainingAmount: double.parse(json['remaining_amount'].toString()),
      progressPercentage: double.parse(json['progress_percentage'].toString()),
    );
  }
}

class GoalInsightsDto extends GoalInsights {
  const GoalInsightsDto({
    required super.monthlyRequired,
    required super.remainingMonths,
    required super.estimatedCompletionMonths,
    required super.message,
  });

  factory GoalInsightsDto.fromJson(Map<String, dynamic> json) {
    return GoalInsightsDto(
      monthlyRequired: json['monthly_required'] != null
          ? double.parse(json['monthly_required'].toString())
          : null,
      remainingMonths: json['remaining_months'] != null
          ? int.parse(json['remaining_months'].toString())
          : null,
      estimatedCompletionMonths: json['estimated_completion_months'] != null
          ? int.parse(json['estimated_completion_months'].toString())
          : null,
      message: json['message'] as String,
    );
  }
}

class GoalDto extends Goal {
  const GoalDto({
    required super.id,
    required super.name,
    required super.category,
    required super.targetAmount,
    super.targetDate,
    required super.priority,
    required super.status,
    super.completedAt,
    required super.createdAt,
    required super.updatedAt,
    super.progress,
    super.insights,
  });

  factory GoalDto.fromJson(Map<String, dynamic> json) {
    return GoalDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String,
      category: GoalCategory.fromString(json['category'] as String),
      targetAmount: double.parse(json['target_amount'].toString()),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      priority: GoalPriority.fromString(
        json['priority'] as String? ?? 'medium',
      ),
      status: GoalStatus.fromString(json['status'] as String? ?? 'active'),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      progress: json['progress'] != null
          ? GoalProgressDto.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      insights: json['insights'] != null
          ? GoalInsightsDto.fromJson(json['insights'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.apiValue,
      'target_amount': targetAmount,
      'target_date': targetDate?.toIso8601String().split('T').first,
      'priority': priority.apiValue,
      'status': status.apiValue,
    };
  }
}
