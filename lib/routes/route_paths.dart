class RoutePaths {
  const RoutePaths._();

  static const home = '/';
  static const fleet = '/fleet';
  static const dashboard = '/dashboard';
  static const customerRequest = '/customer-request';
  static const feasibilityQuotation = '/feasibility-quotation';
  static const workOrderFlow = '/work-order-flow';
  static const fleetManagement = '/fleet-management';
  static const driverManagement = '/driver-management';
  static const complianceInspection = '/compliance-inspection';
  static const journeyManagement = '/journey-management';
  static const tripExecution = '/trip-execution';
  static const deliveryPod = '/delivery-pod';
  static const documentSubmission = '/document-submission';
  static const closure = '/closure';
  static const invoice = '/invoice';
  static const workOrders = '/work-orders';
  static const createWorkOrder = '/work-orders/create';
  static const journeyPlans = '/journey-plans';
  static const alerts = '/alerts';
  static const compliance = '/compliance';
  static const tracking = '/tracking';
  static const roleManagement = '/role-management';
  static const userManagement = '/user-management';
  static const transportManagement = '/transport-management';
  static const vehicleTypes = '/vehicle-types';
  static const vehicleTypeForm = '/vehicle-types/form';
  static const locationMaster = '/location-master';
  static const locationForm = '/location-master/form';
  static const locationView = '/location-master/view/:locationCode';
  static const routeLocationMaster = '/route-location-master';
  static const routeLocationForm = '/route-location-master/form';
  static const routeLocationView = '/route-location-master/view/:routeId';
  static const documentManagement = '/document-management';
  static const roleDocumentMapping = '/role-document-mapping';

  static String locationViewByCode(String locationCode) =>
      '/location-master/view/$locationCode';

  static String routeLocationViewById(String routeId) =>
      '/route-location-master/view/$routeId';
}
