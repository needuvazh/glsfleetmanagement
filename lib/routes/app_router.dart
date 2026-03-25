import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/closure_screen.dart';
import '../presentation/screens/compliance_inspection_screen.dart';
import '../presentation/screens/customer_request_screen.dart';
import '../presentation/screens/delivery_pod_screen.dart';
import '../presentation/screens/document_management_screen.dart';
import '../presentation/screens/document_submission_screen.dart';
import '../presentation/screens/driver_management_screen.dart';
import '../presentation/screens/feasibility_quotation_screen.dart';
import '../presentation/screens/fleet_management_screen.dart';
import '../presentation/screens/invoice_screen.dart';
import '../presentation/screens/journey_management_screen.dart';
import '../presentation/screens/location_form_screen.dart';
import '../presentation/screens/location_list_screen.dart';
import '../presentation/screens/location_view_screen.dart';
import '../presentation/screens/ops_dashboard_screen.dart';
import '../presentation/screens/role_management_screen.dart';
import '../presentation/screens/route_form_screen.dart';
import '../presentation/screens/route_list_screen.dart';
import '../presentation/screens/route_view_screen.dart';
import '../presentation/screens/transport_management_screen.dart';
import '../presentation/screens/trip_execution_screen.dart';
import '../presentation/screens/user_management_screen.dart';
import '../presentation/screens/vehicle_type_form_screen.dart';
import '../presentation/screens/vehicle_type_list_screen.dart';
import '../presentation/screens/work_order_flow_screen.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const OpsDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        builder: (context, state) => const OpsDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.customerRequest,
        builder: (context, state) => const CustomerRequestScreen(),
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
        path: RoutePaths.fleetManagement,
        builder: (context, state) => const FleetManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.driverManagement,
        builder: (context, state) => const DriverManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.complianceInspection,
        builder: (context, state) => const ComplianceInspectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.journeyManagement,
        builder: (context, state) => const JourneyManagementScreen(),
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
        path: RoutePaths.roleManagement,
        builder: (context, state) => const RoleManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.userManagement,
        builder: (context, state) => const UserManagementScreen(),
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
        path: RoutePaths.workOrders,
        redirect: (context, state) => RoutePaths.workOrderFlow,
      ),
      GoRoute(
        path: RoutePaths.fleet,
        redirect: (context, state) => RoutePaths.fleetManagement,
      ),
      GoRoute(
        path: RoutePaths.journeyPlans,
        redirect: (context, state) => RoutePaths.journeyManagement,
      ),
      GoRoute(
        path: RoutePaths.alerts,
        redirect: (context, state) => RoutePaths.tripExecution,
      ),
      GoRoute(
        path: RoutePaths.compliance,
        redirect: (context, state) => RoutePaths.complianceInspection,
      ),
      GoRoute(
        path: RoutePaths.tracking,
        redirect: (context, state) => RoutePaths.tripExecution,
      ),
    ],
  );
});
