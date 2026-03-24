enum WorkOrderStatus { open, inProgress, completed }

extension WorkOrderStatusX on WorkOrderStatus {
  String get label {
    switch (this) {
      case WorkOrderStatus.open:
        return 'Open';
      case WorkOrderStatus.inProgress:
        return 'In Progress';
      case WorkOrderStatus.completed:
        return 'Completed';
    }
  }

  static WorkOrderStatus fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'in progress':
      case 'in_progress':
      case 'inprogress':
        return WorkOrderStatus.inProgress;
      case 'completed':
      case 'done':
      case 'closed':
        return WorkOrderStatus.completed;
      default:
        return WorkOrderStatus.open;
    }
  }
}

enum WorkOrderPriority { high, medium, low }

extension WorkOrderPriorityX on WorkOrderPriority {
  String get label {
    switch (this) {
      case WorkOrderPriority.high:
        return 'High';
      case WorkOrderPriority.medium:
        return 'Medium';
      case WorkOrderPriority.low:
        return 'Low';
    }
  }

  static WorkOrderPriority fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'high':
        return WorkOrderPriority.high;
      case 'low':
        return WorkOrderPriority.low;
      default:
        return WorkOrderPriority.medium;
    }
  }
}

class WorkOrder {
  const WorkOrder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.journeyPlanId,
    required this.estimatedDistance,
    required this.estimatedTime,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.dueDate,
  });

  final String id;
  final String vehicleId;
  final String title;
  final String journeyPlanId;
  final double estimatedDistance;
  final double estimatedTime;
  final WorkOrderPriority priority;
  final WorkOrderStatus status;
  final DateTime createdAt;
  final DateTime dueDate;

  WorkOrder copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? journeyPlanId,
    double? estimatedDistance,
    double? estimatedTime,
    WorkOrderPriority? priority,
    WorkOrderStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      journeyPlanId: journeyPlanId ?? this.journeyPlanId,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
