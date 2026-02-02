import 'package:altin_takip/features/notifications/domain/notification.dart';

class NotificationDto extends Notification {
  const NotificationDto({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.data,
    super.readAt,
    required super.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      data: json['data'] != null
          ? NotificationDataDto.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationDataDto extends NotificationData {
  const NotificationDataDto({
    super.period,
    super.changeAmount,
    super.currentValue,
    super.changePercentage,
    super.chartData,
    super.assets,
  });

  factory NotificationDataDto.fromJson(Map<String, dynamic> json) {
    return NotificationDataDto(
      period: json['period'] as String?,
      changeAmount: (json['change_amount'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      changePercentage: (json['change_percentage'] as num?)?.toDouble(),
      chartData: json['chart_data'] != null
          ? NotificationChartDataDto.fromJson(
              json['chart_data'] as Map<String, dynamic>,
            )
          : null,
      assets: json['assets'] != null
          ? (json['assets'] as List<dynamic>)
                .map(
                  (e) =>
                      NotificationAssetDto.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }
}

class NotificationChartDataDto extends NotificationChartData {
  const NotificationChartDataDto({
    required super.labels,
    required super.values,
  });

  factory NotificationChartDataDto.fromJson(Map<String, dynamic> json) {
    return NotificationChartDataDto(
      labels: (json['labels'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      values: (json['values'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class NotificationAssetDto extends NotificationAsset {
  const NotificationAssetDto({
    required super.amount,
    required super.iconUrl,
    required super.startPrice,
    required super.startValue,
    required super.changeAmount,
    required super.currencyCode,
    required super.currencyName,
    required super.currentPrice,
    required super.currentValue,
    required super.changePercentage,
  });

  factory NotificationAssetDto.fromJson(Map<String, dynamic> json) {
    return NotificationAssetDto(
      amount: (json['amount'] as num).toDouble(),
      iconUrl: json['icon_url'] as String,
      startPrice: (json['start_price'] as num).toDouble(),
      startValue: (json['start_value'] as num).toDouble(),
      changeAmount: (json['change_amount'] as num).toDouble(),
      currencyCode: json['currency_code'] as String,
      currencyName: json['currency_name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      changePercentage: (json['change_percentage'] as num).toDouble(),
    );
  }
}
