import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class OpsDashboardScreen extends ConsumerWidget {
  const OpsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Dashboard',
      currentRoute: RoutePaths.home,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final dashboard = data.dashboard;
          final width = MediaQuery.sizeOf(context).width;
          final isMobile = width < 800;

          return RefreshIndicator(
            onRefresh: ref.read(logisticsViewModelProvider.notifier).refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _TopHubCard(lastUpdated: data.lastUpdated),
                const SizedBox(height: 16),
                _KpiBand(dashboard: dashboard),
                const SizedBox(height: 16),
                if (isMobile)
                  Column(
                    children: [
                      _ActiveOrdersCard(orders: data.workOrders),
                      const SizedBox(height: 16),
                      _RoutePerformanceCard(journeys: data.journeyMaster),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ActiveOrdersCard(orders: data.workOrders)),
                      const SizedBox(width: 16),
                      Expanded(child: _RoutePerformanceCard(journeys: data.journeyMaster)),
                    ],
                  ),
                const SizedBox(height: 16),
                if (isMobile)
                  Column(
                    children: [
                      _ActiveFleetTable(vehicles: data.vehicles, ivms: data.ivms),
                      const SizedBox(height: 16),
                      _WeeklyTripCard(ivms: data.ivms),
                      const SizedBox(height: 16),
                      _FleetStatusCard(vehicles: data.vehicles),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ActiveFleetTable(vehicles: data.vehicles, ivms: data.ivms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _WeeklyTripCard(ivms: data.ivms)),
                    ],
                  ),
                const SizedBox(height: 16),
                if (isMobile)
                  Column(
                    children: [
                      _ComplianceCard(state: data),
                      const SizedBox(height: 16),
                      _SmartAlertsCard(alerts: data.executionAlerts),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ComplianceCard(state: data)),
                      const SizedBox(width: 16),
                      Expanded(child: _SmartAlertsCard(alerts: data.executionAlerts)),
                    ],
                  ),
                const SizedBox(height: 16),
                _FleetStatusCard(vehicles: data.vehicles),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopHubCard extends StatelessWidget {
  const _TopHubCard({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    return OpsSectionCard(
      title: 'Transport Operations Hub',
      subtitle: 'Muscat Operations • ${_fmt(lastUpdated)}',
      icon: Icons.hub_outlined,
      accent: const Color(0xFF2563EB),
      trailing: const OpsPill(label: 'LIVE', color: Color(0xFF16A34A)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('Export Report'),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_task),
            label: const Text('New Work Order'),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final d = '${dt.day}/${dt.month}/${dt.year}';
    final t =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$d • $t';
  }
}

class _KpiBand extends StatelessWidget {
  const _KpiBand({required this.dashboard});

  final DashboardSnapshot dashboard;

  @override
  Widget build(BuildContext context) {
    final cards = <_SummaryMetric>[
      _SummaryMetric(
        title: 'Active Trips',
        value: '${dashboard.activeTrips}',
        subtitle: '+4 today',
        icon: Icons.route_outlined,
        color: const Color(0xFF16A34A),
      ),
      _SummaryMetric(
        title: 'On-time KPI',
        value: '${(88 + (dashboard.activeTrips % 8))}%',
        subtitle: '+2.1% week',
        icon: Icons.schedule_outlined,
        color: const Color(0xFF0EA5E9),
      ),
      _SummaryMetric(
        title: 'Fleet Utilization',
        value: '${(70 + dashboard.fleetAvailable * 3).clamp(55, 95)}%',
        subtitle: 'target 80%',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFFF59E0B),
      ),
      _SummaryMetric(
        title: 'Active Alerts',
        value: '${dashboard.driverAlerts}',
        subtitle: '${dashboard.delayedTrips} critical',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFDC2626),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100 ? 4 : (width >= 800 ? 2 : 1);
        final gap = 16.0;
        final itemWidth = (width - ((crossAxisCount - 1) * gap)) / crossAxisCount;
        const itemHeight = 140.0;
        final childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => _SummaryCard(metric: cards[index]),
        );
      },
    );
  }
}

class _SummaryMetric {
  const _SummaryMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.metric});

  final _SummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: const Color(0x1A0B1A33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(metric.icon, color: metric.color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metric.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.subtitle,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({required this.activeTrips});

  final int activeTrips;

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('Order Intake', max(1, activeTrips ~/ 3)),
      ('AI Feasibility', max(1, activeTrips ~/ 4)),
      ('Supervisor Review', max(1, activeTrips ~/ 5)),
      ('WO Generated', max(1, activeTrips ~/ 3)),
      ('In Transit', max(1, activeTrips)),
      ('Delivered', max(1, activeTrips ~/ 2)),
    ];

    return OpsSectionCard(
      title: 'Live Order Pipeline',
      subtitle: 'GLS-IMS-PF02',
      icon: Icons.sync_alt_outlined,
      accent: const Color(0xFF14B8A6),
      trailing: const OpsPill(label: 'AI ASSISTED', color: Color(0xFF14B8A6)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final stage in stages)
            Container(
              width: 150,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF4F8FF),
                border: Border.all(color: const Color(0xFFDAE7F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage.$1, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 3),
                  Text(
                    '${stage.$2}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WeeklyTripCard extends StatelessWidget {
  const _WeeklyTripCard({required this.ivms});

  final List<IvmsData> ivms;

  @override
  Widget build(BuildContext context) {
    final bars = [
      52.0,
      68.0,
      61.0,
      84.0,
      76.0,
      48.0,
      58.0,
    ];

    final active = ivms.where((e) => e.status.toLowerCase() == 'moving').length;

    return OpsSectionCard(
      title: 'Weekly Trip Performance',
      subtitle: 'THIS WEEK',
      icon: Icons.bar_chart_outlined,
      accent: const Color(0xFF2563EB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _miniMetric('Total Trips', (150 + active).toString()),
              _miniMetric('Active/Day', max(1, active).toString()),
              _miniMetric('Avg Speed', _avg(ivms).toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < bars.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: bars[i],
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i]),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static double _avg(List<IvmsData> data) {
    if (data.isEmpty) {
      return 0;
    }
    final total = data.fold<double>(0, (sum, item) => sum + item.speed);
    return total / data.length;
  }

  Widget _miniMetric(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _FleetStatusCard extends StatelessWidget {
  const _FleetStatusCard({required this.vehicles});

  final List<FleetVehicleData> vehicles;

  @override
  Widget build(BuildContext context) {
    final onTrip = vehicles.where((e) => e.status.toLowerCase().contains('trip')).length;
    final available =
        vehicles.where((e) => e.status.toLowerCase().contains('available')).length;
    final maintenance =
        vehicles.where((e) => e.status.toLowerCase().contains('maint')).length;
    final total = max(1, vehicles.length);

    return OpsSectionCard(
      title: 'Fleet Status Breakdown',
      subtitle: '$total VEHICLES',
      icon: Icons.pie_chart_outline,
      accent: const Color(0xFFF59E0B),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: onTrip / total,
                      strokeWidth: 16,
                      color: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFFE8EDF8),
                    ),
                  ),
                  SizedBox(
                    width: 105,
                    height: 105,
                    child: CircularProgressIndicator(
                      value: maintenance / total,
                      strokeWidth: 14,
                      color: const Color(0xFFF59E0B),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Text(
                    '$total\nvehicles',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _legend('On Trip', onTrip, const Color(0xFF10B981)),
          _legend('Available', available, const Color(0xFF2563EB)),
          _legend('Maintenance', maintenance, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _legend(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$value'),
        ],
      ),
    );
  }
}

class _ActiveFleetTable extends StatelessWidget {
  const _ActiveFleetTable({required this.vehicles, required this.ivms});

  final List<FleetVehicleData> vehicles;
  final List<IvmsData> ivms;

  @override
  Widget build(BuildContext context) {
    final rows = vehicles.take(5).toList();

    return OpsSectionCard(
      title: 'Active Fleet Status',
      subtitle: 'LIVE - ${vehicles.length} VEHICLES',
      icon: Icons.table_chart_outlined,
      accent: const Color(0xFF2563EB),
      child: rows.isEmpty
          ? const SizedBox(height: 120, child: Center(child: Text('No fleet records')))
          : Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: Text('Fleet', style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(child: Text('Type', style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                    SizedBox(width: 64, child: Text('Speed', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 6),
                for (int i = 0; i < rows.length; i++) ...[
                  const Divider(height: 1),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(child: Text(rows[i].vehicleNo)),
                      Expanded(child: Text(_hardcodedVehicleClass(rows[i].vehicleNo))),
                      Expanded(child: Text(rows[i].status)),
                      SizedBox(
                        width: 64,
                        child: Text(
                          _speedFor(rows[i].vehicleNo).toStringAsFixed(0),
                          style: TextStyle(
                            color: _speedFor(rows[i].vehicleNo) > 80
                                ? const Color(0xFFDC2626)
                                : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                ],
              ],
            ),
    );
  }

  double _speedFor(String vehicleNo) {
    for (final item in ivms) {
      if (item.vehicleId == vehicleNo) {
        return item.speed;
      }
    }
    return 0;
  }

  String _hardcodedVehicleClass(String vehicleNo) {
    if (vehicleNo == '8603 BK') {
      return 'Dry Movers';
    }
    if (vehicleNo == '24567 A') {
      return 'Rigid Truck';
    }
    if (vehicleNo == '99876 M') {
      return 'Container';
    }
    return 'Vehicle Class';
  }
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.state});

  final LogisticsUiState state;

  @override
  Widget build(BuildContext context) {
    final total = state.complianceChecklist.length;
    final passed = state.complianceChecklist.values.where((v) => v).length;
    final percent = total == 0 ? 0 : ((passed / total) * 100).round();

    return OpsSectionCard(
      title: 'Compliance Dashboard',
      subtitle: 'AI MONITORED',
      icon: Icons.verified_user_outlined,
      accent: const Color(0xFF16A34A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _progressRow('JMP Compliance', percent / 100, const Color(0xFF16A34A)),
          _progressRow('IVMS / DFMS Coverage', 0.88, const Color(0xFF2563EB)),
          _progressRow('License Validity', 0.95, const Color(0xFF10B981)),
          _progressRow('PDO SP-2000', 0.76, const Color(0xFFD97706)),
          _progressRow('RAS Inspections', 0.89, const Color(0xFF059669)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFEAF8EF),
              border: Border.all(color: const Color(0xFFD2EEDD)),
            ),
            child: Text(
              'AI Notice: ${max(0, total - passed)} checks pending attention.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('${(value * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: const Color(0xFFE8EDF8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartAlertsCard extends StatelessWidget {
  const _SmartAlertsCard({required this.alerts});

  final List<String> alerts;

  @override
  Widget build(BuildContext context) {
    final top = alerts.take(3).toList();

    return OpsSectionCard(
      title: 'Smart Alerts',
      subtitle: 'ACTIVE',
      icon: Icons.notification_important_outlined,
      accent: const Color(0xFFDC2626),
      child: top.isEmpty
          ? const SizedBox(height: 100, child: Center(child: Text('No alerts')))
          : Column(
              children: [
                for (int i = 0; i < top.length; i++) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: i == 0
                          ? const Color(0xFFFFF1F1)
                          : (i == 1
                              ? const Color(0xFFFFF8EA)
                              : const Color(0xFFF2F6FF)),
                      border: Border.all(color: const Color(0xFFE6DFD6)),
                    ),
                    child: Text(top[i]),
                  ),
                  if (i != top.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _ActiveOrdersCard extends StatelessWidget {
  const _ActiveOrdersCard({required this.orders});

  final List<WorkOrderFlowItem> orders;

  @override
  Widget build(BuildContext context) {
    final items = orders.take(4).toList();

    return OpsSectionCard(
      title: 'Active Work Orders',
      subtitle: 'View all',
      icon: Icons.assignment_outlined,
      accent: const Color(0xFF2563EB),
      child: items.isEmpty
          ? const SizedBox(height: 120, child: Center(child: Text('No work orders')))
          : Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF4F8FF),
                      border: Border.all(color: const Color(0xFFD7E3F8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                items[i].woId,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(items[i].status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(items[i].cargo),
                        const SizedBox(height: 2),
                        Text(items[i].route),
                      ],
                    ),
                  ),
                  if (i != items.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class _RoutePerformanceCard extends StatelessWidget {
  const _RoutePerformanceCard({required this.journeys});

  final List<JourneyMasterData> journeys;

  @override
  Widget build(BuildContext context) {
    final rows = journeys.isEmpty
        ? [
            ('Muscat -> Salalah', 0.94),
            ('Muscat -> Sohar', 0.89),
            ('Muscat -> Nizwa', 0.80),
            ('Sohar -> Duqm', 0.92),
          ]
        : journeys.map((j) {
            final score = (0.7 + (j.stops.length * 0.05)).clamp(0.75, 0.96);
            return ('${j.origin} -> ${j.destination}', score);
          }).toList();

    return OpsSectionCard(
      title: 'Route Performance - On-Time Delivery %',
      subtitle: 'THIS MONTH',
      icon: Icons.insights_outlined,
      accent: const Color(0xFF14B8A6),
      child: Column(
        children: [
          for (final row in rows) ...[
            Row(
              children: [
                SizedBox(width: 180, child: Text(row.$1)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: row.$2,
                      minHeight: 14,
                      color: row.$2 >= 0.9
                          ? const Color(0xFF10B981)
                          : (row.$2 >= 0.85
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFF87171)),
                      backgroundColor: const Color(0xFFE8EDF8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard({required this.ivms});

  final List<IvmsData> ivms;

  @override
  Widget build(BuildContext context) {
    return OpsSectionCard(
      title: 'Live Fleet Map',
      subtitle: 'IVMS LIVE • Mock coordinates',
      icon: Icons.public_outlined,
      accent: const Color(0xFF2563EB),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF2F6FD),
          border: Border.all(color: const Color(0xFFD9E3F4)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _GridPattern()),
            for (int i = 0; i < ivms.length; i++)
              Positioned(
                left: 30.0 + (i * 120),
                top: 40.0 + (i.isEven ? 60 : 140),
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ivms[i].speed > 80
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF10B981),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(ivms[i].vehicleId, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Row(
                children: const [
                  _MapLegend('Moving', Color(0xFF10B981)),
                  SizedBox(width: 8),
                  _MapLegend('Alert', Color(0xFFDC2626)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPattern extends StatelessWidget {
  const _GridPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9E3F4)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapLegend extends StatelessWidget {
  const _MapLegend(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard({required this.alerts, required this.state});

  final List<String> alerts;
  final LogisticsUiState state;

  @override
  Widget build(BuildContext context) {
    final msg1 = alerts.isEmpty ? 'No active alerts' : alerts.first;
    final msg2 =
        '${state.dashboard.activeTrips} active trips. Recommend standby units for long corridors.';

    return OpsSectionCard(
      title: 'AI Operations Assistant',
      subtitle: 'CLAUDE AI',
      icon: Icons.smart_toy_outlined,
      accent: const Color(0xFF7C3AED),
      child: Column(
        children: [
          _aiBubble('GLS AI • NOW', msg1),
          const SizedBox(height: 8),
          _aiBubble('GLS AI • TODAY', msg2),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              OpsPill(label: 'Pending Quotes', color: Color(0xFF2563EB)),
              OpsPill(label: 'Compliance', color: Color(0xFF16A34A)),
              OpsPill(label: 'Delay Report', color: Color(0xFFF59E0B)),
              OpsPill(label: 'License Check', color: Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aiBubble(String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF4F7FF),
        border: Border.all(color: const Color(0xFFDFE6FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(message),
        ],
      ),
    );
  }
}
