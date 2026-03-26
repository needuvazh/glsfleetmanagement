import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/change_password_screen.dart';
import '../presentation/screens/alerts_screen.dart';
import '../presentation/screens/assignments_screen.dart';
import '../presentation/screens/closure_screen.dart';
import '../presentation/screens/customer_management_screen.dart';
import '../presentation/screens/customer_form_screen.dart';
import '../presentation/screens/customer_request_screen.dart';
import '../presentation/screens/customer_request_form_screen.dart';
import '../presentation/screens/customer_request_view_screen.dart';
import '../presentation/screens/customer_view_screen.dart';
import '../presentation/screens/enquiry_details_screen.dart';
import '../presentation/screens/create_work_order_screen.dart';
import '../presentation/screens/compliance_dashboard_screen.dart';
import '../presentation/screens/dispatch_readiness_screen.dart';
import '../presentation/screens/delivery_pod_screen.dart';
import '../presentation/screens/document_management_screen.dart';
import '../presentation/screens/document_submission_screen.dart';
import '../presentation/screens/driver_detail_screen.dart';
import '../presentation/screens/driver_management_screen.dart';
import '../presentation/screens/feasibility_quotation_screen.dart';
import '../presentation/screens/fleet_detail_screen.dart';
import '../presentation/screens/fleet_management_screen.dart';
import '../presentation/screens/forgot_password_screen.dart';
import '../presentation/screens/invoice_screen.dart';
import '../presentation/screens/inspection_approval_screen.dart';
import '../presentation/screens/inspection_calendar_screen.dart';
import '../presentation/screens/inspection_create_screen.dart';
import '../presentation/screens/inspection_detail_screen.dart';
import '../presentation/screens/inspection_failed_queue_screen.dart';
import '../presentation/screens/inspection_list_screen.dart';
import '../presentation/screens/inspection_template_management_screen.dart';
import '../presentation/screens/journey_management_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/location_form_screen.dart';
import '../presentation/screens/location_list_screen.dart';
import '../presentation/screens/location_view_screen.dart';
import '../presentation/screens/media_gallery_screen.dart';
import '../presentation/screens/media_preview_screen.dart';
import '../presentation/screens/ops_dashboard_screen.dart';
import '../presentation/screens/reports_screen.dart';
import '../presentation/screens/role_form_screen.dart';
import '../presentation/screens/role_list_screen.dart';
import '../presentation/screens/route_form_screen.dart';
import '../presentation/screens/route_list_screen.dart';
import '../presentation/screens/route_view_screen.dart';
import '../presentation/screens/transport_management_screen.dart';
import '../presentation/screens/trip_monitoring_screen.dart';
import '../presentation/screens/trip_execution_screen.dart';
import '../presentation/screens/user_form_screen.dart';
import '../presentation/screens/user_list_screen.dart';
import '../presentation/screens/user_profile_screen.dart';
import '../presentation/screens/user_view_screen.dart';
import '../presentation/screens/role_view_screen.dart';
import '../presentation/screens/vendor_form_screen.dart';
import '../presentation/screens/vendor_list_screen.dart';
import '../presentation/screens/vendor_view_screen.dart';
import '../presentation/screens/vehicle_type_form_screen.dart';
import '../presentation/screens/vehicle_type_list_screen.dart';
import '../presentation/screens/work_order_flow_screen.dart';
import '../presentation/screens/work_order_detail_screen.dart';
import '../presentation/screens/work_orders_screen.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.login,
    routes: [
      // Authentication Routes
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.userProfile,
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      // Main Application Routes
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const OpsDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        builder: (context, state) => const OpsDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerManagement,
        builder: (context, state) => const CustomerManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerForm,
        builder: (context, state) => CustomerFormScreen(
          customerId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RoutePaths.customerView,
        builder: (context, state) => CustomerViewScreen(
          customerId: state.pathParameters['customerId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.customerRequest,
        builder: (context, state) => const CustomerRequestScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerRequestForm,
        builder: (context, state) => CustomerRequestFormScreen(
          enquiryNumber: state.uri.queryParameters['enquiryNumber'],
        ),
      ),
      GoRoute(
        path: RoutePaths.customerRequestView,
        builder: (context, state) => CustomerRequestViewScreen(
          enquiryNumber: state.pathParameters['enquiryNumber'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.enquiryDetails,
        builder: (context, state) => const EnquiryDetailsScreen(),
      ),
      GoRoute(
        path: RoutePaths.feasibilityQuotation,
        builder: (context, state) => const FeasibilityQuotationScreen(),
      ),
      GoRoute(
        path: RoutePaths.workOrderFlow,
        builder: (context, state) => const WorkOrderFlowScreen(),
      ),
      GoRoute(
        path: RoutePaths.workOrders,
        builder: (context, state) => const WorkOrdersScreen(),
      ),
      GoRoute(
        path: RoutePaths.assignments,
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: RoutePaths.createWorkOrder,
        builder: (context, state) => CreateWorkOrderScreen(
          editWorkOrderId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RoutePaths.workOrderDetail,
        builder: (context, state) => WorkOrderDetailScreen(
          workOrderId: state.pathParameters['workOrderId'] ?? 'Unknown',
          initialTab: state.uri.queryParameters['tab'],
        ),
      ),
      GoRoute(
        path: RoutePaths.fleetManagement,
        builder: (context, state) => const FleetManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.fleetDetail,
        builder: (context, state) => FleetDetailScreen(
          fleetId: state.pathParameters['fleetId'] ?? 'Unknown',
          initialTab: state.uri.queryParameters['tab'],
        ),
      ),
      GoRoute(
        path: RoutePaths.driverManagement,
        builder: (context, state) => const DriverManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.driverDetail,
        builder: (context, state) => DriverDetailScreen(
          driverId: state.pathParameters['driverId'] ?? 'Unknown',
          initialTab: state.uri.queryParameters['tab'],
        ),
      ),
      GoRoute(
        path: RoutePaths.complianceDashboard,
        builder: (context, state) => const ComplianceDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.dispatchReadiness,
        builder: (context, state) => const DispatchReadinessScreen(),
      ),
      GoRoute(
        path: RoutePaths.alerts,
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: RoutePaths.mediaGallery,
        builder: (context, state) => const MediaGalleryScreen(),
      ),
      GoRoute(
        path: RoutePaths.mediaPreview,
        builder: (context, state) => MediaPreviewScreen(
          evidenceId: state.pathParameters['evidenceId'] ?? 'Unknown',
        ),
      ),
      GoRoute(
        path: RoutePaths.inspections,
        builder: (context, state) => const InspectionListScreen(),
      ),
      GoRoute(
        path: RoutePaths.inspectionCreate,
        builder: (context, state) => const InspectionCreateScreen(),
      ),
      GoRoute(
        path: RoutePaths.inspectionTemplates,
        builder: (context, state) => const InspectionTemplateManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.inspectionFailedQueue,
        builder: (context, state) => const InspectionFailedQueueScreen(),
      ),
      GoRoute(
        path: RoutePaths.inspectionCalendar,
        builder: (context, state) => const InspectionCalendarScreen(),
      ),
      GoRoute(
        path: RoutePaths.inspectionApproval,
        builder: (context, state) => InspectionApprovalScreen(
          inspectionId: state.pathParameters['inspectionId'] ?? 'Unknown',
        ),
      ),
      GoRoute(
        path: RoutePaths.inspectionDetail,
        builder: (context, state) => InspectionDetailScreen(
          inspectionId: state.pathParameters['inspectionId'] ?? 'Unknown',
        ),
      ),
      GoRoute(
        path: RoutePaths.complianceInspection,
        redirect: (context, state) => RoutePaths.inspections,
      ),
      GoRoute(
        path: RoutePaths.journeyManagement,
        builder: (context, state) => const JourneyManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.tripMonitoring,
        builder: (context, state) => const TripMonitoringScreen(),
      ),
      GoRoute(
        path: RoutePaths.tripExecution,
        builder: (context, state) => const TripExecutionScreen(),
      ),
      GoRoute(
        path: RoutePaths.deliveryPod,
        builder: (context, state) => const DeliveryPodScreen(),
      ),
      GoRoute(
        path: RoutePaths.documentSubmission,
        builder: (context, state) => const DocumentSubmissionScreen(),
      ),
      GoRoute(
        path: RoutePaths.closure,
        builder: (context, state) => const ClosureScreen(),
      ),
      GoRoute(
        path: RoutePaths.invoice,
        builder: (context, state) => const InvoiceScreen(),
      ),
      GoRoute(
        path: RoutePaths.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: RoutePaths.roleManagement,
        builder: (context, state) => const RoleListScreen(),
      ),
      GoRoute(
        path: RoutePaths.roleForm,
        builder: (context, state) => RoleFormScreen(
          editRoleId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RoutePaths.roleView,
        builder: (context, state) => RoleViewScreen(
          roleId: state.pathParameters['roleId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.userManagement,
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: RoutePaths.userForm,
        builder: (context, state) => UserFormScreen(
          editUserId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RoutePaths.userView,
        builder: (context, state) => UserViewScreen(
          userId: state.pathParameters['userId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.transportManagement,
        builder: (context, state) => const TransportManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.vehicleTypes,
        builder: (context, state) => const VehicleTypeListScreen(),
      ),
      GoRoute(
        path: RoutePaths.vehicleTypeForm,
        builder: (context, state) => VehicleTypeFormScreen(
          editCode: state.uri.queryParameters['code'],
        ),
      ),
      GoRoute(
        path: RoutePaths.vendorMaster,
        builder: (context, state) => const VendorListScreen(),
      ),
      GoRoute(
        path: RoutePaths.vendorForm,
        builder: (context, state) => VendorFormScreen(
          editVendorId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RoutePaths.vendorView,
        builder: (context, state) => VendorViewScreen(
          vendorId: state.pathParameters['vendorId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.locationMaster,
        builder: (context, state) => const LocationListScreen(),
      ),
      GoRoute(
        path: RoutePaths.locationForm,
        builder: (context, state) => LocationFormScreen(
          editCode: state.uri.queryParameters['code'],
        ),
      ),
      GoRoute(
        path: RoutePaths.locationView,
        builder: (context, state) => LocationViewScreen(
          locationCode: state.pathParameters['locationCode'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.routeLocationMaster,
        builder: (context, state) => const RouteListScreen(),
      ),
      GoRoute(
        path: RoutePaths.routeLocationForm,
        builder: (context, state) => RouteFormScreen(
          editRouteId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RoutePaths.routeLocationView,
        builder: (context, state) => RouteViewScreen(
          routeId: state.pathParameters['routeId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.documentManagement,
        builder: (context, state) => const DocumentManagementScreen(),
      ),
      // Legacy aliases to keep older links functional.
      GoRoute(
        path: RoutePaths.fleet,
        redirect: (context, state) => RoutePaths.fleetManagement,
      ),
      GoRoute(
        path: RoutePaths.journeyPlans,
        redirect: (context, state) => RoutePaths.journeyManagement,
      ),
      GoRoute(
        path: RoutePaths.compliance,
        redirect: (context, state) => RoutePaths.complianceDashboard,
      ),
      GoRoute(
        path: RoutePaths.tracking,
        redirect: (context, state) => RoutePaths.tripMonitoring,
      ),
      GoRoute(
        path: RoutePaths.roleDocumentMapping,
        redirect: (context, state) => RoutePaths.documentManagement,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
