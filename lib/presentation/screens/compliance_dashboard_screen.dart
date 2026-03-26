import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/cargo_model.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/cargo_viewmodel.dart';
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
    final cargo = ref.watch(cargoViewModelProvider);

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
          final cargoItems = cargo.valueOrNull?.items ?? const <CargoModel>[];
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

          final cargoAlerts = _buildCargoAlerts(
            logisticsData.workOrders,
            cargoItems,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final count = width >= 1200 ? 3 : (width >= 760 ? 2 : 1);

              return ListView(
                children: [
                  GridView.builder(
                    itemCount: widgets.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.75,
                    ),
                    itemBuilder: (context, index) => widgets[index],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cargo Compliance Alerts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Warnings generated from cargo master behavior rules.',
                          ),
                          const SizedBox(height: 10),
                          if (cargoAlerts.isEmpty)
                            const Text(
                                'No cargo-driven compliance warnings at this time.')
                          else
                            for (final alert in cargoAlerts)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                child: Text(alert),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<String> _buildCargoAlerts(
    List<WorkOrderFlowItem> workOrders,
    List<CargoModel> cargoItems,
  ) {
    final alerts = <String>[];
    for (final order in workOrders) {
      CargoModel? profile;
      for (final cargo in cargoItems) {
        if (cargo.cargoName.toLowerCase() == order.cargo.toLowerCase()) {
          profile = cargo;
          break;
        }
      }
      if (profile == null) {
        continue;
      }

      final needsAttention = profile.specialComplianceRequired ||
          profile.authorityApprovalNeeded ||
          profile.hazardous ||
          profile.requiredCertifications.isNotEmpty ||
          profile.requiredPermits.isNotEmpty;
      if (!needsAttention) {
        continue;
      }

      final certs = profile.requiredCertifications.join(', ');
      final permits = profile.requiredPermits.join(', ');
      final points = <String>[];
      if (profile.hazardous) {
        points.add('hazardous handling');
      }
      if (profile.specialComplianceRequired) {
        points.add('special compliance');
      }
      if (profile.authorityApprovalNeeded) {
        points.add('authority approval');
      }
      if (certs.isNotEmpty) {
        points.add('certifications: $certs');
      }
      if (permits.isNotEmpty) {
        points.add('permits: $permits');
      }

      alerts.add(
        '${order.woId} (${order.customer}) - ${profile.cargoName}: ${points.join(' | ')}',
      );
    }
    return alerts;
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
                  color: color.withValues(alpha: 0.12),
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
