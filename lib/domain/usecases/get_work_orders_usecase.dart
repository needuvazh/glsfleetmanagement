import '../entities/work_order.dart';
import '../repositories/work_order_repository.dart';

class GetWorkOrdersUseCase {
  const GetWorkOrdersUseCase(this._repository);

  final WorkOrderRepository _repository;

  Future<List<WorkOrder>> call() {
    return _repository.getWorkOrders();
  }
}
