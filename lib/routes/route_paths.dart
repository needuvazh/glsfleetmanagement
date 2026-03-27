class RoutePaths {
  const RoutePaths._();

  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/';
  static const fleet = '/fleet';
  static const dashboard = '/dashboard';
  static const customerManagement = '/customer-management';
  static const customerForm = '/customer-management/form';
  static const customerView = '/customer-management/view/:customerId';
  static const customerRequest = '/customer-request';
  static const customerRequestForm = '/customer-request/form';
  static const customerRequestView = '/customer-request/view/:enquiryNumber';
  static const enquiryDetails = '/enquiry-details';
  static const feasibilityReview = '/feasibility-review';
  static const feasibilityReviewDetail = '/feasibility-review/:enquiryNumber';
  static const workOrderFlow = '/work-order-flow';
  static const fleetManagement = '/fleet-management';
  static const fleetDetail = '/fleet-management/:fleetId';
  static const driverManagement = '/driver-management';
  static const driverForm = '/driver-management/form';
  static const driverDetail = '/driver-management/:driverId';
  static const complianceInspection = '/compliance-inspection';
  static const complianceDashboard = '/compliance-dashboard';
  static const dispatchReadiness = '/dispatch-readiness';
  static const inspections = '/inspections';
  static const inspectionDashboard = '/inspection-dashboard';
  static const inspectionCreate = '/inspections/create';
  static const inspectionDetail = '/inspections/:inspectionId';
  static const inspectionApproval = '/inspections/:inspectionId/approval';
  static const inspectionTemplates = '/inspections/templates';
  static const inspectionTemplateForm = '/inspections/templates/form';
  static const inspectionTemplateView = '/inspections/templates/view/:templateId';
  static const inspectionFailedQueue = '/inspections/failed-queue';
  static const inspectionCalendar = '/inspections/calendar';
  static const mediaGallery = '/media-gallery';
  static const mediaPreview = '/media-preview/:evidenceId';
  static const journeyManagement = '/journey-management';
  static const journeyManagementDetail = '/journey-management/:jmpId';
  static const tripMonitoring = '/trips';
  static const tripExecution = '/trip-execution';
  static const deliveryPod = '/delivery-pod';
  static const documentSubmission = '/document-submission';
  static const closure = '/closure';
  static const invoice = '/invoice';
  static const reports = '/reports';
  static const workOrders = '/work-orders';
  static const assignmentList = '/assignment-list';
  static const String resourceAssignment = '/resource-assignment';
  static const String complianceReadiness = '/operations/compliance-readiness';
  static const workOrderDetail = '/work-orders/:workOrderId';
  static const editWorkOrder = '/work-orders/:workOrderId/edit';
  static const assignSupervisor = '/work-orders/:workOrderId/assign-supervisor';
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
  static const locationMaster = '/location-master';
  static const locationForm = '/location-master/form';
  static const locationView = '/location-master/view/:locationCode';
  static const routeLocationMaster = '/route-location-master';
  static const routeLocationForm = '/route-location-master/form';
  static const routeLocationView = '/route-location-master/view/:routeId';
  static const cargoMaster = '/cargo-master';
  static const cargoMasterForm = '/cargo-master/form';
  static const cargoMasterView = '/cargo-master/view/:cargoCode';
  static const documentManagement = '/document-management';
  static const userProfile = '/user-profile';
  static const changePassword = '/change-password';

  // New Placeholders from Transaction Screen Matrix Requirement
  static const quotation = '/quotation';
  static const quotationForm = '/quotation/form';
  static const quotationEdit = '/quotation/:quoteRef/edit';
  static const quotationDecision = '/quotation/:quoteRef/decision';
  static String quotationEditByRef(String ref) => '/quotation/${Uri.encodeComponent(ref)}/edit';
  static String quotationDecisionByRef(String ref) => '/quotation/${Uri.encodeComponent(ref)}/decision';
  static const orderDecision = '/order-decision';
  static const woDelegation = '/wo-delegation';
  static const dispatch = '/dispatch';
  static const tripDocumentVerification = '/trip-document-verification';
  static const finalApproval = '/final-approval';
  static const financeHandoff = '/finance-handoff';
  static const executionEvidence = '/execution-evidence';
  static const podDnUploads = '/pod-dn-uploads';
  static const tripDocuments = '/trip-documents';
  static const photosVideos = '/photos-videos';
  static const auditTrail = '/audit-trail';
  static const statusTimeline = '/status-timeline';
  static const trailerMaster = '/trailer';
  static const trailerForm = '/trailer/form';
  static const trailerView = '/trailer/view/:trailerCode';
  static const trailerMasterLegacy = '/trailer-master';


  static String workOrderDetailById(String workOrderId) =>
      '/work-orders/$workOrderId';

  static String editWorkOrderById(String workOrderId) =>
      '/work-orders/$workOrderId/edit';

  static String assignSupervisorById(String workOrderId) =>
      '/work-orders/$workOrderId/assign-supervisor';

  static String customerRequestViewById(String enquiryNumber) =>
      '/customer-request/view/$enquiryNumber';

  static String customerViewById(String customerId) =>
      '/customer-management/view/$customerId';

  static String editCustomerById(String customerId) =>
      '/customer-management/form?id=$customerId';

  static String roleViewById(String roleId) => '/role-management/view/$roleId';

  static String userViewById(String userId) => '/user-management/view/$userId';

  static String vendorViewById(String vendorId) =>
      '/vendor-master/view/$vendorId';

  static String locationViewByCode(String locationCode) =>
      '/location-master/view/$locationCode';

  static String routeLocationViewById(String routeId) =>
      '/route-location-master/view/$routeId';

  static String cargoMasterViewByCode(String cargoCode) =>
      '/cargo-master/view/$cargoCode';

  static String fleetDetailById(String fleetId) => '/fleet-management/$fleetId';

  static String driverDetailById(String driverId) =>
      '/driver-management/$driverId';

  static String editDriverById(String driverId) =>
      '/driver-management/form?id=$driverId';

  static String inspectionDetailById(String inspectionId) =>
      '/inspections/$inspectionId';

  static String inspectionApprovalById(String inspectionId) =>
      '/inspections/$inspectionId/approval';
  static String inspectionTemplateViewById(String templateId) =>
      '/inspections/templates/view/$templateId';
  static String editInspectionTemplateById(String templateId) =>
      '/inspections/templates/form?id=$templateId';
  static String trailerViewByCode(String trailerCode) =>
      '/trailer/view/${Uri.encodeComponent(trailerCode)}';
  static String editTrailerByCode(String trailerCode) =>
      '/trailer/form?code=${Uri.encodeComponent(trailerCode)}';

  static String mediaPreviewById(String evidenceId) =>
      '/media-preview/$evidenceId';
  static String feasibilityReviewById(String enquiryNumber) =>
      '/feasibility-review/$enquiryNumber';

  static String resourceAssignmentById(String workOrderId) =>
      '$resourceAssignment?workOrderId=$workOrderId';

  static String journeyManagementDetailById(String jmpId) =>
      '/journey-management/$jmpId';
}
