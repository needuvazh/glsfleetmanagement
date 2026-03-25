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
  static const fleetDetail = '/fleet-management/:fleetId';
  static const driverManagement = '/driver-management';
  static const driverDetail = '/driver-management/:driverId';
  static const complianceInspection = '/compliance-inspection';
  static const complianceDashboard = '/compliance-dashboard';
  static const dispatchReadiness = '/dispatch-readiness';
  static const inspections = '/inspections';
  static const inspectionCreate = '/inspections/create';
  static const inspectionDetail = '/inspections/:inspectionId';
  static const inspectionApproval = '/inspections/:inspectionId/approval';
  static const inspectionTemplates = '/inspections/templates';
  static const inspectionFailedQueue = '/inspections/failed-queue';
  static const inspectionCalendar = '/inspections/calendar';
  static const mediaGallery = '/media-gallery';
  static const mediaPreview = '/media-preview/:evidenceId';
  static const journeyManagement = '/journey-management';
  static const tripMonitoring = '/trips';
  static const tripExecution = '/trip-execution';
  static const deliveryPod = '/delivery-pod';
  static const documentSubmission = '/document-submission';
  static const closure = '/closure';
  static const invoice = '/invoice';
  static const reports = '/reports';
  static const workOrders = '/work-orders';
  static const assignments = '/assignments';
  static const workOrderDetail = '/work-orders/:workOrderId';
  static const createWorkOrder = '/work-orders/create';
  static const journeyPlans = '/journey-plans';
  static const alerts = '/alerts';
  static const compliance = '/compliance';
  static const tracking = '/tracking';
  static const roleManagement = '/role-management';
  static const roleForm = '/role-management/form';
  static const roleView = '/role-management/view/:roleId';
  static const userManagement = '/user-management';
  static const userForm = '/user-management/form';
  static const userView = '/user-management/view/:userId';
  static const transportManagement = '/transport-management';
  static const vehicleTypes = '/vehicle-types';
  static const vehicleTypeForm = '/vehicle-types/form';
  static const vendorMaster = '/vendor-master';
  static const vendorForm = '/vendor-master/form';
  static const vendorView = '/vendor-master/view/:vendorId';
  static const documentManagement = '/document-management';
  static const roleDocumentMapping = '/role-document-mapping';
  static const userProfile = '/user-profile';
  static const changePassword = '/change-password';

  static String workOrderDetailById(String workOrderId) =>
      '/work-orders/$workOrderId';
  static String roleViewById(String roleId) => '/role-management/view/$roleId';
  static String vendorViewById(String vendorId) =>
      '/vendor-master/view/$vendorId';
  static String userViewById(String userId) => '/user-management/view/$userId';

  static String fleetDetailById(String fleetId) => '/fleet-management/$fleetId';

  static String driverDetailById(String driverId) =>
      '/driver-management/$driverId';

  static String inspectionDetailById(String inspectionId) =>
      '/inspections/$inspectionId';

  static String inspectionApprovalById(String inspectionId) =>
      '/inspections/$inspectionId/approval';

  static String mediaPreviewById(String evidenceId) =>
      '/media-preview/$evidenceId';
}
