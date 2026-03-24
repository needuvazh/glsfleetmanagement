import '../entities/work_order.dart';

abstract class WorkOrderRepository {
  Future<List<WorkOrder>> getWorkOrders();
}
