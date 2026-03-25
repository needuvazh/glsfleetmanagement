import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/compliance_viewmodel.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class ComplianceDashboardScreen extends ConsumerWidget {
  const ComplianceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logistics = ref.watch(logisticsViewModelProvider);
    final inspections = ref.watch(inspectionViewModelProvider);
    final compliance = ref.watch(complianceViewModelProvider);

    return OpsShell(
      title: 'Compliance Dashboard',
      currentRoute: RoutePaths.complianceDashboard,
      actions: [
        FilledButton.icon(
          onPressed: () => context.push(RoutePaths.dispatchReadiness),
          icon: const Icon(Icons.rule_folder_outlined),
          label: const Text('Open Dispatch Readiness'),
        ),
        const SizedBox(width: 8),
      ],
      child: logistics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (logisticsData) {
          final now = DateTime.now();

          final expiringLicenses = logisticsData.drivers.where((driver) {
            final expiry = DateTime.tryParse(driver.expiryDate.trim());
            if (expiry == null) {
              return false;
            }
            final days = expiry.difference(now).inDays;
            return days >= 0 && days <= 30;
          }).length;

          final expiringVehicleDocuments =
              compliance.valueOrNull?.expiringCount ?? 0;

          final overdueInspections = inspections.items.where((item) {
            final due = item.nextInspectionDate ??
                item.inspectedAt.add(const Duration(days: 30));
            return due.isBefore(DateTime(now.year, now.month, now.day));
          }).length;

          final failedInspections = inspections.items
              .where((item) => item.overallResult == InspectionResult.failed)
              .length;

          final unresolvedComplianceAlerts = logisticsData.executionAlerts
              .where((alert) => alert != 'No critical alerts now.')
              .length;

          final dispatchBlockedCases =
              inspections.items.where((item) => item.dispatchBlocked).length;

          final widgets = [
            _ComplianceMetric(
              title: 'Expiring Licenses',
              value: expiringLicenses,
              subtitle: 'Within next 30 days',
              icon: Icons.badge_outlined,
              color: const Color(0xFFD97706),
              onTap: () => context.push(RoutePaths.driverManagement),
            ),
            _ComplianceMetric(
              title: 'Expiring Vehicle Documents',
              value: expiringVehicleDocuments,
              subtitle: 'Registration/insurance risk',
              icon: Icons.local_shipping_outlined,
              color: const Color(0xFFD97706),
              onTap: () => context.push(RoutePaths.fleetManagement),
            ),
            _ComplianceMetric(
              title: 'Overdue Inspections',
              value: overdueInspections,
              subtitle: 'Inspection due date crossed',
              icon: Icons.event_busy_outlined,
              color: const Color(0xFFB91C1C),
              onTap: () => context.push(RoutePaths.inspectionCalendar),
            ),
            _ComplianceMetric(
              title: 'Failed Inspections',
              value: failedInspections,
              subtitle: 'Immediate corrective action',
              icon: Icons.report_problem_outlined,
              color: const Color(0xFFB91C1C),
              onTap: () => context.push(RoutePaths.inspectionFailedQueue),
            ),
            _ComplianceMetric(
              title: 'Unresolved Compliance Alerts',
              value: unresolvedComplianceAlerts,
              subtitle: 'Open risk alerts needing action',
              icon: Icons.notifications_active_outlined,
              color: const Color(0xFF7C3AED),
              onTap: () => context.push(RoutePaths.tripExecution),
            ),
            _ComplianceMetric(
              title: 'Dispatch Blocked Cases',
              value: dispatchBlockedCases,
              subtitle: 'Blocked by critical compliance',
              icon: Icons.block_outlined,
              color: const Color(0xFFB91C1C),
              onTap: () => context.push(RoutePaths.dispatchReadiness),
            ),
          ];

          return GridView.builder(
            itemCount: widgets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.75,
            ),
            itemBuilder: (context, index) => widgets[index],
          );
        },
      ),
    );
  }
}

class _ComplianceMetric extends StatelessWidget {
  const _ComplianceMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                '$value',
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
      ),
    );
  }
}
