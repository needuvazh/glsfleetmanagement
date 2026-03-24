import '../entities/logistics_flow.dart';
import '../repositories/logistics_repository.dart';

class GetLogisticsDataUseCase {
  const GetLogisticsDataUseCase(this._repository);

  final LogisticsRepository _repository;

  Future<List<CustomerRequestData>> getCustomerRequests() {
    return _repository.getCustomerRequests();
  }

  Future<List<QuotationData>> getQuotations() {
    return _repository.getQuotations();
  }

  Future<List<WorkOrderFlowItem>> getFlowWorkOrders() {
    return _repository.getFlowWorkOrders();
  }

  Future<List<FleetVehicleData>> getVehicles() {
    return _repository.getVehicles();
  }

  Future<List<DriverData>> getDrivers() {
    return _repository.getDrivers();
  }

  Future<List<JourneyMasterData>> getJourneyMaster() {
    return _repository.getJourneyMaster();
  }

  Future<List<IvmsData>> getIvmsData() {
    return _repository.getIvmsData();
  }

  Future<List<DfmsData>> getDfmsData() {
    return _repository.getDfmsData();
  }
}
