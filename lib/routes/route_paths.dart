class RoutePaths {
  const RoutePaths._();

  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/';
  static const fleet = '/fleet';
  static const dashboard = '/dashboard';
  static const customerManagement = '/customer-management';
  static const customerRequest = '/customer-request';
  static const feasibilityQuotation = '/feasibility-quotation';
  static const workOrderFlow = '/work-order-flow';
  static const fleetManagement = '/fleet-management';
  static const driverManagement = '/driver-management';
  static const complianceInspection = '/compliance-inspection';
  static const journeyManagement = '/journey-management';
  static const tripMonitoring = '/trips';
  static const tripExecution = '/trip-execution';
  static const deliveryPod = '/delivery-pod';
  static const documentSubmission = '/document-submission';
  static const closure = '/closure';
  static const invoice = '/invoice';
  static const workOrders = '/work-orders';
  static const assignments = '/assignments';
  static const workOrderDetail = '/work-orders/:workOrderId';
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
  static const documentManagement = '/document-management';
  static const roleDocumentMapping = '/role-document-mapping';
  static const userProfile = '/user-profile';
  static const changePassword = '/change-password';

  static String workOrderDetailById(String workOrderId) =>
      '/work-orders/$workOrderId';
}
