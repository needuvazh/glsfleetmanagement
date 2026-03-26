class AppConstants {
  const AppConstants._();

  static const appName = 'Transport Fleet Management';

  // Toggle between API and local mock JSON.
  // true  -> Live API
  // false -> assets/mock/*.json
  static const useLiveApi = false;

  static const apiBaseUrl = 'https://your-api-domain.com/api';

  static const dashboardEndpoint = '/dashboard';
  static const fleetEndpoint = '/fleet';
  static const workOrdersEndpoint = '/work-orders';
  static const alertsEndpoint = '/alerts';
  static const complianceEndpoint = '/compliance';
  static const trackingEndpoint = '/tracking';
  static const journeyPlansEndpoint = '/journey-plans';
  static const vehiclesEndpoint = '/vehicles';
  static const driversEndpoint = '/drivers';
  static const journeyMasterEndpoint = '/journey-master';
  static const ivmsEndpoint = '/ivms';
  static const dfmsEndpoint = '/dfms';
  static const flowWorkOrdersEndpoint = '/flow-work-orders';
  static const customerRequestsEndpoint = '/customer-requests';
  static const quotationsEndpoint = '/quotations';

  static const dashboardMockPath = 'assets/mock/dashboard.json';
  static const fleetMockPath = 'assets/mock/fleet.json';
  static const workOrdersMockPath = 'assets/mock/work_orders.json';
  static const alertsMockPath = 'assets/mock/alerts.json';
  static const complianceMockPath = 'assets/mock/compliance.json';
  static const journeyPlansMockPath = 'assets/mock/journey_plan.json';
  static const vehiclesMockPath = 'assets/mock/vehicles.json';
  static const driversMockPath = 'assets/mock/drivers.json';
  static const journeyMasterMockPath = 'assets/mock/journey.json';
  static const ivmsMockPath = 'assets/mock/ivms_data.json';
  static const dfmsMockPath = 'assets/mock/dfms_data.json';
  static const flowWorkOrdersMockPath = 'assets/mock/work_orders.json';
  static const customerRequestsMockPath = 'assets/mock/requests.json';
  static const quotationsMockPath = 'assets/mock/quotations.json';
  static const customersMockPath = 'assets/mock/customers.json';
  static const requestsMockPath = 'assets/mock/requests.json';
  static const deliveryMockPath = 'assets/mock/delivery.json';
  static const invoicesMockPath = 'assets/mock/invoices.json';
  static const vehicleTypesMockPath = 'assets/mock/vehicle_types.json';
  static const moduleDocumentsMockPath = 'assets/mock/module_documents.json';

  // Cargo enforcement mode is controlled at runtime from Cargo Master UI.
}
