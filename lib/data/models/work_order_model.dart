import '../../domain/entities/work_order.dart';

class WorkOrderModel extends WorkOrder {
  const WorkOrderModel({
    required super.id,
    required super.vehicleId,
    required super.title,
    required super.journeyPlanId,
    required super.estimatedDistance,
    required super.estimatedTime,
    required super.priority,
    required super.status,
    required super.createdAt,
    required super.dueDate,
  });

  factory WorkOrderModel.fromMap(Map<String, dynamic> map) {
    final woId = map['id'] as String? ?? map['woId'] as String? ?? '';
    final vehicleId =
        map['vehicleId'] as String? ?? map['vehicleNumber'] as String? ?? '';
    final title = map['title'] as String? ?? map['route'] as String? ?? 'Transport Work Order';
    final journeyPlanId = map['journeyPlanId'] as String? ?? map['requestId'] as String? ?? '';
    final statusRaw = map['status'] as String? ?? '';
    return WorkOrderModel(
      id: woId,
      vehicleId: vehicleId,
      title: title,
      journeyPlanId: journeyPlanId,
      estimatedDistance: (map['estimatedDistance'] as num?)?.toDouble() ?? 0,
      estimatedTime: (map['estimatedTime'] as num?)?.toDouble() ?? 0,
      priority: WorkOrderPriorityX.fromString(map['priority'] as String? ?? ''),
      status: WorkOrderStatusX.fromString(statusRaw),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
