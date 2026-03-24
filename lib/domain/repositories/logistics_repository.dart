import '../entities/logistics_flow.dart';

abstract class LogisticsRepository {
  Future<List<CustomerRequestData>> getCustomerRequests();
  Future<List<QuotationData>> getQuotations();
  Future<List<WorkOrderFlowItem>> getFlowWorkOrders();
  Future<List<FleetVehicleData>> getVehicles();
  Future<List<DriverData>> getDrivers();
  Future<List<JourneyMasterData>> getJourneyMaster();
  Future<List<IvmsData>> getIvmsData();
  Future<List<DfmsData>> getDfmsData();
}
