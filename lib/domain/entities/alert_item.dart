enum AlertSeverity { high, medium, low }

extension AlertSeverityX on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.low:
        return 'Low';
    }
  }

  static AlertSeverity fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'high':
      case 'critical':
        return AlertSeverity.high;
      case 'low':
        return AlertSeverity.low;
      default:
        return AlertSeverity.medium;
    }
  }
}

class AlertItem {
  const AlertItem({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  final String id;
  final String vehicleId;
  final String type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  AlertItem copyWith({
    String? id,
    String? vehicleId,
    String? type,
    AlertSeverity? severity,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AlertItem(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
