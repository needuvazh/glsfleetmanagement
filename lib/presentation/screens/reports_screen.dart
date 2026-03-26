import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/compliance_viewmodel.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logistics = ref.watch(logisticsViewModelProvider);
    final inspections = ref.watch(inspectionViewModelProvider).items;
    final compliance = ref.watch(complianceViewModelProvider);

    return OpsShell(
      title: 'Reports',
      currentRoute: RoutePaths.reports,
      child: logistics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final now = DateTime.now();
          final complianceItems = compliance.valueOrNull?.items ?? const [];

          final inspectionPassed = inspections
              .where((item) => item.overallResult == InspectionResult.passed)
              .length;
          final inspectionFailed = inspections
              .where((item) => item.overallResult == InspectionResult.failed)
              .length;
          final overdueInspection = inspections.where((item) {
            final due = item.nextInspectionDate ??
                item.inspectedAt.add(const Duration(days: 30));
            return due.isBefore(DateTime(now.year, now.month, now.day));
          }).length;

          final workOrderCompleted = data.workOrders
              .where((item) => item.status.toLowerCase().contains('complete'))
              .length;
          final delayedTrips = data.workOrders
              .where((item) => item.status.toLowerCase().contains('delay'))
              .length;

          final activeFleet = data.vehicles
              .where((item) => item.status.toLowerCase().contains('active'))
              .length;
          final fleetUtilization = data.vehicles.isEmpty
              ? 0
              : ((activeFleet / data.vehicles.length) * 100).round();

          final documentExpiry = complianceItems
              .where((item) => item.complianceStatus
                  .toString()
                  .toLowerCase()
                  .contains('expiring'))
              .length;

          final unresolvedAlerts = data.executionAlerts
              .where((alert) => alert != 'No critical alerts now.')
              .length;

          final routeBuckets = <String, int>{};
          final delayedByRoute = <String, int>{};
          var highRiskTrips = 0;
          for (final wo in data.workOrders) {
            final routeKey = wo.routeName.isNotEmpty
                ? wo.routeName
                : (wo.routeCode.isNotEmpty ? wo.routeCode : wo.route);
            routeBuckets[routeKey] = (routeBuckets[routeKey] ?? 0) + 1;
            if (wo.status.toLowerCase().contains('delay')) {
              delayedByRoute[routeKey] = (delayedByRoute[routeKey] ?? 0) + 1;
            }
            final risk = wo.routeRiskLevel.toLowerCase();
            if (risk == 'high' || risk == 'critical') {
              highRiskTrips += 1;
            }
          }
          final routesTracked = routeBuckets.length;
          var delayedRouteCount = 0;
          delayedByRoute.forEach((_, value) {
            if (value > 0) {
              delayedRouteCount += 1;
            }
          });

          final cards = [
            _ReportTile(
              title: 'Inspection Pass/Fail Report',
              primary: '$inspectionPassed / $inspectionFailed',
              subtitle: 'Passed vs failed inspections',
              color: const Color(0xFF2563EB),
              icon: Icons.fact_check_outlined,
            ),
            _ReportTile(
              title: 'Overdue Inspection Report',
              primary: '$overdueInspection',
              subtitle: 'Inspection records overdue',
              color: const Color(0xFFB91C1C),
              icon: Icons.event_busy_outlined,
            ),
            _ReportTile(
              title: 'Work Order Completion Summary',
              primary: '$workOrderCompleted/${data.workOrders.length}',
              subtitle: 'Completed work orders',
              color: const Color(0xFF15803D),
              icon: Icons.assignment_turned_in_outlined,
            ),
            _ReportTile(
              title: 'Delayed Trip Summary',
              primary: '$delayedTrips',
              subtitle: 'Trips with delay flags',
              color: const Color(0xFFD97706),
              icon: Icons.timer_off_outlined,
            ),
            _ReportTile(
              title: 'Fleet Utilization Summary',
              primary: '$fleetUtilization%',
              subtitle: '$activeFleet active of ${data.vehicles.length}',
              color: const Color(0xFF7C3AED),
              icon: Icons.local_shipping_outlined,
            ),
            _ReportTile(
              title: 'Document Expiry Report',
              primary: '$documentExpiry',
              subtitle: 'Documents expiring soon',
              color: const Color(0xFFB45309),
              icon: Icons.description_outlined,
            ),
            _ReportTile(
              title: 'Unresolved Alert Report',
              primary: '$unresolvedAlerts',
              subtitle: 'Open operational alerts',
              color: const Color(0xFFDC2626),
              icon: Icons.notification_important_outlined,
            ),
            _ReportTile(
              title: 'Route Coverage',
              primary: '$routesTracked',
              subtitle: 'Unique routes used in operations',
              color: const Color(0xFF0F766E),
              icon: Icons.route_outlined,
            ),
            _ReportTile(
              title: 'Delayed Routes',
              primary: '$delayedRouteCount',
              subtitle: 'Routes with delay occurrences',
              color: const Color(0xFFB45309),
              icon: Icons.warning_amber_outlined,
            ),
            _ReportTile(
              title: 'High Risk Route Trips',
              primary: '$highRiskTrips',
              subtitle: 'Trips tagged high/critical risk',
              color: const Color(0xFFB91C1C),
              icon: Icons.priority_high_outlined,
            ),
          ];

          return GridView.builder(
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) => cards[index],
          );
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.title,
    required this.primary,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String primary;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              primary,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
