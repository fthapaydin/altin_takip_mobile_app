import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int id;
  final String title;
  final String body;
  final String type;
  final NotificationData? data;
  final DateTime? readAt;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  Notification copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    NotificationData? data,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, data, readAt, createdAt];
}

class NotificationData extends Equatable {
  final String? period;
  final double? changeAmount;
  final double? currentValue;
  final double? changePercentage;
  final NotificationChartData? chartData;
  final List<NotificationAsset>? assets;

  const NotificationData({
    this.period,
    this.changeAmount,
    this.currentValue,
    this.changePercentage,
    this.chartData,
    this.assets,
  });

  @override
  List<Object?> get props => [
    period,
    changeAmount,
    currentValue,
    changePercentage,
    chartData,
    assets,
  ];
}

class NotificationChartData extends Equatable {
  final List<String> labels;
  final List<double> values;

  const NotificationChartData({required this.labels, required this.values});

  @override
  List<Object?> get props => [labels, values];
}

class NotificationAsset extends Equatable {
  final double amount;
  final String iconUrl;
  final double startPrice;
  final double startValue;
  final double changeAmount;
  final String currencyCode;
  final String currencyName;
  final double currentPrice;
  final double currentValue;
  final double changePercentage;

  const NotificationAsset({
    required this.amount,
    required this.iconUrl,
    required this.startPrice,
    required this.startValue,
    required this.changeAmount,
    required this.currencyCode,
    required this.currencyName,
    required this.currentPrice,
    required this.currentValue,
    required this.changePercentage,
  });

  @override
  List<Object?> get props => [
    amount,
    iconUrl,
    startPrice,
    startValue,
    changeAmount,
    currencyCode,
    currencyName,
    currentPrice,
    currentValue,
    changePercentage,
  ];
}
