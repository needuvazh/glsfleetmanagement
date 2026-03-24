import '../../domain/entities/alert_item.dart';

class AlertItemModel extends AlertItem {
  const AlertItemModel({
    required super.id,
    required super.vehicleId,
    required super.type,
    required super.severity,
    required super.message,
    required super.timestamp,
    required super.isRead,
  });

  factory AlertItemModel.fromMap(Map<String, dynamic> map) {
    return AlertItemModel(
      id: map['id'] as String? ?? '',
      vehicleId: map['vehicleId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      severity: AlertSeverityX.fromString(map['severity'] as String? ?? ''),
      message: map['message'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}
