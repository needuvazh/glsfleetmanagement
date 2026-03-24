import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/data_source_mode_provider.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/alert_item.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/entities/fleet.dart';
import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/work_order.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/alerts_viewmodel.dart';
import '../viewmodels/compliance_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/fleet_viewmodel.dart';
import '../viewmodels/journey_plan_viewmodel.dart';
import '../viewmodels/theme_mode_viewmodel.dart';
import '../viewmodels/work_orders_viewmodel.dart';
import '../widgets/dashboard_mileage_chart.dart';
import '../widgets/dashboard_status_pie_chart.dart';
import '../widgets/kpi_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useLiveApi = ref.watch(useLiveApiProvider);
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 270,
              child: _OpsSidebar(useLiveApi: useLiveApi),
            ),
            const VerticalDivider(width: 1),
            const Expanded(child: _OperationsHubContent()),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Operations Hub'),
        actions: [
          IconButton(
            tooltip: useLiveApi ? 'Switch to Mock JSON' : 'Switch to Live API',
            onPressed: () {
              ref.read(useLiveApiProvider.notifier).toggle();
            },
            icon: Icon(
              useLiveApi ? Icons.cloud_done_outlined : Icons.dataset_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: _OpsSidebar(useLiveApi: useLiveApi, isDrawer: true),
        ),
      ),
      body: const _OperationsHubContent(),
    );
  }
}

class _OpsSidebar extends ConsumerWidget {
  const _OpsSidebar({required this.useLiveApi, this.isDrawer = false});

  final bool useLiveApi;
  final bool isDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsViewModelProvider).valueOrNull;
    final workOrders = ref.watch(workOrdersViewModelProvider).valueOrNull;

    final items = [
      _NavItem('Live Dashboard', Icons.dashboard_rounded, RoutePaths.home),
      _NavItem('Fleet Tracker', Icons.local_shipping_outlined, RoutePaths.fleet),
      _NavItem('Work Orders', Icons.assignment_outlined, RoutePaths.workOrders,
          badge: workOrders?.items.length),
      _NavItem('Journey Plans', Icons.alt_route_outlined, RoutePaths.journeyPlans),
      _NavItem('Alerts', Icons.notification_important_outlined, RoutePaths.alerts,
          badge: alerts?.unreadCount),
      _NavItem('Compliance', Icons.verified_user_outlined, RoutePaths.compliance),
      _NavItem('Live Tracking', Icons.map_outlined, RoutePaths.tracking),
    ];

    final current = GoRouterState.of(context).uri.path;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7FAFF), Color(0xFFF1F5FB)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFDCEEFE),
                  child: Icon(Icons.hub_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GLS-IMS',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Transport ODS Platform',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, index) {
                final item = items[index];
                final selected = current == item.route;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (isDrawer) {
                      Navigator.of(context).pop();
                    }
                    context.go(item.route);
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? const Color(0xFFE5EFFC)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(item.label)),
                        if ((item.badge ?? 0) > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(0xFFEFF3FF),
                            ),
                            child: Text(
                              '${item.badge}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('AI Engine Active')),
                        Text(
                          useLiveApi ? 'API' : 'MOCK',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                ref.read(themeModeProvider.notifier).toggleTheme(),
                            icon: const Icon(Icons.dark_mode_outlined, size: 16),
                            label: const Text('Theme'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                ref.read(useLiveApiProvider.notifier).toggle(),
                            icon: const Icon(Icons.swap_horiz, size: 16),
                            label: const Text('Source'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route, {this.badge});

  final String label;
  final IconData icon;
  final String route;
  final int? badge;
}

class _OperationsHubContent extends ConsumerWidget {
  const _OperationsHubContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardViewModelProvider).valueOrNull;
    final fleet = ref.watch(fleetViewModelProvider).valueOrNull;
    final alerts = ref.watch(alertsViewModelProvider).valueOrNull;
    final compliance = ref.watch(complianceViewModelProvider).valueOrNull;
    final workOrders = ref.watch(workOrdersViewModelProvider).valueOrNull;
    final journeyPlans = ref.watch(journeyPlanViewModelProvider).valueOrNull;

    final kpis = dashboard?.data.kpis;

    final List<MileagePoint> mileagePoints = dashboard?.mileageByRange ?? const [];
    final List<StatusShare> statusShare =
        dashboard?.data.vehicleStatusShare ?? const [];

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(dashboardViewModelProvider.notifier).refresh(),
          ref.read(fleetViewModelProvider.notifier).refresh(),
          ref.read(alertsViewModelProvider.notifier).refresh(),
          ref.read(complianceViewModelProvider.notifier).refresh(),
          ref.read(workOrdersViewModelProvider.notifier).refresh(),
          ref.read(journeyPlanViewModelProvider.notifier).refresh(),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _HubTopBar(
            onNewOrder: () => context.push(RoutePaths.createWorkOrder),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 5),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isMobile ? 2.6 : 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              KpiCard(
                title: 'Active Trips',
                value: '${kpis?.activeVehicles ?? 0}',
                subtitle: 'Fleet units on route',
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF0EA5E9),
              ),
              KpiCard(
                title: 'On-Time KPI',
                value: '${(84 + ((kpis?.activeVehicles ?? 0) % 12)).toStringAsFixed(0)}%',
                subtitle: '+2.1% this week',
                icon: Icons.schedule_outlined,
                color: const Color(0xFF16A34A),
              ),
              KpiCard(
                title: 'Fleet Utilization',
                value: '${(kpis == null ? 0 : ((kpis.activeVehicles / max(1, kpis.totalVehicles)) * 100)).toStringAsFixed(0)}%',
                subtitle: 'Target 80%',
                icon: Icons.pie_chart_outline,
                color: const Color(0xFFF59E0B),
              ),
              KpiCard(
                title: 'JMP Compliance',
                value: '${_complianceRate(compliance)}%',
                subtitle: 'Route plan adherence',
                icon: Icons.verified_outlined,
                color: const Color(0xFF2563EB),
              ),
              KpiCard(
                title: 'Active Alerts',
                value: '${alerts?.unreadCount ?? 0}',
                subtitle: 'Needs action',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PipelineCard(activeFleet: fleet?.filteredItems.length ?? 0),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              children: [
                _CardSection(
                  title: 'Weekly Trip Performance',
                  child: SizedBox(
                    height: 280,
                    child: DashboardMileageChart(points: mileagePoints),
                  ),
                ),
                const SizedBox(height: 12),
                _CardSection(
                  title: 'Fleet Status Breakdown',
                  child: SizedBox(
                    height: 280,
                    child: DashboardStatusPieChart(items: statusShare),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _CardSection(
                    title: 'Weekly Trip Performance',
                    child: SizedBox(
                      height: 280,
                      child: DashboardMileageChart(points: mileagePoints),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardSection(
                    title: 'Fleet Status Breakdown',
                    child: SizedBox(
                      height: 280,
                      child: DashboardStatusPieChart(items: statusShare),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              children: [
                _ActiveFleetStatusCard(fleets: fleet?.filteredItems ?? const []),
                const SizedBox(height: 12),
                _CompliancePanel(compliance: compliance),
                const SizedBox(height: 12),
                _SmartAlertsPanel(alerts: alerts?.filteredItems ?? const []),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      _ActiveFleetStatusCard(fleets: fleet?.filteredItems ?? const []),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _CompliancePanel(compliance: compliance),
                      const SizedBox(height: 12),
                      _SmartAlertsPanel(alerts: alerts?.filteredItems ?? const []),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              children: [
                _ActiveOrdersPanel(orders: workOrders?.filteredItems ?? const []),
                const SizedBox(height: 12),
                _RoutePerformancePanel(plans: journeyPlans?.filteredItems ?? const []),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ActiveOrdersPanel(orders: workOrders?.filteredItems ?? const []),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _RoutePerformancePanel(
                    plans: journeyPlans?.filteredItems ?? const [],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              children: [
                _MiniMapCard(fleets: fleet?.filteredItems ?? const []),
                const SizedBox(height: 12),
                _AiAssistantCard(
                  alertsCount: alerts?.unreadCount ?? 0,
                  activeTrips: fleet?.filteredItems
                          .where((item) => item.status == FleetStatus.active)
                          .length ??
                      0,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _MiniMapCard(fleets: fleet?.filteredItems ?? const []),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _AiAssistantCard(
                    alertsCount: alerts?.unreadCount ?? 0,
                    activeTrips: fleet?.filteredItems
                            .where((item) => item.status == FleetStatus.active)
                            .length ??
                        0,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static int _complianceRate(ComplianceUiState? state) {
    if (state == null || state.items.isEmpty) {
      return 0;
    }
    final rate = (state.compliantCount / state.items.length) * 100;
    return rate.round();
  }
}

class _HubTopBar extends StatelessWidget {
  const _HubTopBar({required this.onNewOrder});

  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transport Operations Hub',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Muscat Operations • ${DateTime.now().toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export started (mock)')),
                );
              },
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('Export Report'),
            ),
            FilledButton.icon(
              onPressed: onNewOrder,
              icon: const Icon(Icons.add_task),
              label: const Text('New Work Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({required this.activeFleet});

  final int activeFleet;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Order Intake', max(2, activeFleet ~/ 5)),
      ('AI Feasibility', max(2, activeFleet ~/ 6)),
      ('Supervisor Review', max(2, activeFleet ~/ 7)),
      ('Work Assigned', max(2, activeFleet ~/ 5)),
      ('In Transit', max(2, activeFleet ~/ 3)),
      ('Delivered', max(1, activeFleet ~/ 4)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Order Pipeline',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final step in steps)
                  Container(
                    width: 146,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCE3F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.$1,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          '${step.$2}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActiveFleetStatusCard extends StatelessWidget {
  const _ActiveFleetStatusCard({required this.fleets});

  final List<Fleet> fleets;

  @override
  Widget build(BuildContext context) {
    final list = fleets.take(6).toList();

    return _CardSection(
      title: 'Active Fleet Status',
      child: list.isEmpty
          ? const SizedBox(height: 120, child: Center(child: Text('No fleet data')))
          : Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: Text('Fleet')),
                    Expanded(child: Text('Driver')),
                    Expanded(child: Text('Status')),
                    SizedBox(width: 64, child: Text('Fuel')),
                  ],
                ),
                const SizedBox(height: 6),
                for (int i = 0; i < list.length; i++) ...[
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text(list[i].vehicleNumber)),
                      Expanded(child: Text(list[i].driver)),
                      Expanded(child: Text(list[i].status.label)),
                      SizedBox(
                        width: 64,
                        child: Text('${list[i].fuelLevel}%'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _CompliancePanel extends StatelessWidget {
  const _CompliancePanel({required this.compliance});

  final ComplianceUiState? compliance;

  @override
  Widget build(BuildContext context) {
    final total = compliance?.items.length ?? 0;
    final compliant = compliance?.compliantCount ?? 0;
    final expiring = compliance?.expiringCount ?? 0;
    final overdue = compliance?.overdueCount ?? 0;

    final rates = [
      ('JMP Compliance', total == 0 ? 0.0 : compliant / total, const Color(0xFF16A34A)),
      ('IVMS/DFMS Coverage', total == 0 ? 0.0 : (1 - (overdue / max(1, total))),
          const Color(0xFF2563EB)),
      ('License Validity', total == 0 ? 0.0 : (1 - (expiring / max(1, total))),
          const Color(0xFF0EA5E9)),
      ('PDO SP-2000', 0.76, const Color(0xFFD97706)),
      ('RAS Inspections', 0.89, const Color(0xFF059669)),
    ];

    return _CardSection(
      title: 'Compliance Dashboard',
      child: Column(
        children: [
          for (final row in rates) ...[
            Row(
              children: [
                Expanded(child: Text(row.$1)),
                Text('${(row.$2 * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: row.$2,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              color: row.$3,
              backgroundColor: const Color(0xFFE7ECF6),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFEAF8EF),
              border: Border.all(color: const Color(0xFFCCE9D8)),
            ),
            child: Text(
              'AI Notice: $expiring certificates expiring soon. Auto-reminders triggered.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartAlertsPanel extends StatelessWidget {
  const _SmartAlertsPanel({required this.alerts});

  final List<AlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    final top = alerts.take(3).toList();

    return _CardSection(
      title: 'Smart Alerts',
      child: top.isEmpty
          ? const SizedBox(height: 110, child: Center(child: Text('No active alerts')))
          : Column(
              children: [
                for (int i = 0; i < top.length; i++) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: top[i].severity.label == 'High'
                          ? const Color(0xFFFFF1F1)
                          : const Color(0xFFFFF8EA),
                      border: Border.all(color: const Color(0xFFE8DFCF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${top[i].type} - ${top[i].vehicleId}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(top[i].message),
                      ],
                    ),
                  ),
                  if (i != top.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _ActiveOrdersPanel extends StatelessWidget {
  const _ActiveOrdersPanel({required this.orders});

  final List<WorkOrder> orders;

  @override
  Widget build(BuildContext context) {
    final top = orders.take(4).toList();

    return _CardSection(
      title: 'Active Work Orders',
      child: top.isEmpty
          ? const SizedBox(height: 120, child: Center(child: Text('No active work orders')))
          : Column(
              children: [
                for (int i = 0; i < top.length; i++) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF4F8FF),
                      border: Border.all(color: const Color(0xFFDCE6F8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          top[i].id,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(top[i].title),
                        const SizedBox(height: 4),
                        Text('Vehicle ${top[i].vehicleId} • ${top[i].status.label}'),
                      ],
                    ),
                  ),
                  if (i != top.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _RoutePerformancePanel extends StatelessWidget {
  const _RoutePerformancePanel({required this.plans});

  final List<JourneyPlan> plans;

  @override
  Widget build(BuildContext context) {
    final rows = plans.isEmpty
        ? [
            ('Muscat -> Salalah', 0.93, const Color(0xFF10B981)),
            ('Muscat -> PDO', 0.89, const Color(0xFF34D399)),
            ('Muscat -> Nizwa', 0.81, const Color(0xFFF87171)),
          ]
        : plans.map((plan) {
            final base = 0.72 + ((plan.distance % 100) / 1000);
            final score = min(0.97, base + (plan.stops.length * 0.03));
            final color = score >= 0.9
                ? const Color(0xFF10B981)
                : (score >= 0.85
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFF87171));
            return (
              '${plan.origin} -> ${plan.destination}',
              score,
              color,
            );
          }).toList();

    return _CardSection(
      title: 'Route Performance - On-Time Delivery %',
      child: Column(
        children: [
          for (final row in rows) ...[
            Row(
              children: [
                SizedBox(width: 150, child: Text(row.$1)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: row.$2,
                    minHeight: 14,
                    borderRadius: BorderRadius.circular(6),
                    color: row.$3,
                    backgroundColor: const Color(0xFFE8EDF8),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(row.$2 * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MiniMapCard extends StatelessWidget {
  const _MiniMapCard({required this.fleets});

  final List<Fleet> fleets;

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'Live Fleet Map - Oman',
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF4F8FF),
          border: Border.all(color: const Color(0xFFDDE7F8)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapGridPainter(),
              ),
            ),
            for (final marker in _normalize(fleets))
              Positioned(
                left: marker.$1,
                top: marker.$2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marker.$3,
                    border: Border.all(color: Colors.white, width: 1.8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static List<(double, double, Color)> _normalize(List<Fleet> fleets) {
    if (fleets.isEmpty) {
      return [];
    }
    var minLat = fleets.first.latitude;
    var maxLat = fleets.first.latitude;
    var minLng = fleets.first.longitude;
    var maxLng = fleets.first.longitude;

    for (final fleet in fleets) {
      minLat = min(minLat, fleet.latitude);
      maxLat = max(maxLat, fleet.latitude);
      minLng = min(minLng, fleet.longitude);
      maxLng = max(maxLng, fleet.longitude);
    }

    final latSpan = max(0.0001, maxLat - minLat);
    final lngSpan = max(0.0001, maxLng - minLng);

    return fleets.take(12).map((fleet) {
      final x = 10 + ((fleet.longitude - minLng) / lngSpan) * 320;
      final y = 10 + (1 - ((fleet.latitude - minLat) / latSpan)) * 180;
      final color = switch (fleet.status) {
        FleetStatus.active => const Color(0xFF22C55E),
        FleetStatus.maintenance => const Color(0xFFF59E0B),
        FleetStatus.idle => const Color(0xFF3B82F6),
      };
      return (x, y, color);
    }).toList();
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFFD8E3F5)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y <= size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard({
    required this.alertsCount,
    required this.activeTrips,
  });

  final int alertsCount;
  final int activeTrips;

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'AI Operations Assistant',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AiBubble(
            label: 'GLS AI • NOW',
            text:
                'Detected $alertsCount active alerts. Suggested dispatch review for high-severity incidents first.',
          ),
          const SizedBox(height: 10),
          _AiBubble(
            label: 'GLS AI • TODAY',
            text:
                '$activeTrips trips are active. Recommend assigning standby units to North corridor.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _AiTag('Pending Quotes'),
              _AiTag('Compliance'),
              _AiTag('Delay Report'),
              _AiTag('License Check'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDEE6FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }
}

class _AiTag extends StatelessWidget {
  const _AiTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFFE9EEF9),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
