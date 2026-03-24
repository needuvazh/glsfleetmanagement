import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/dashboard.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_mileage_chart.dart';
import '../widgets/dashboard_status_pie_chart.dart';
import '../widgets/kpi_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DashboardError(
          message: error.toString(),
          onRetry: ref.read(dashboardViewModelProvider.notifier).refresh,
        ),
        data: (state) {
          final kpis = state.data.kpis;
          final notifier = ref.read(dashboardViewModelProvider.notifier);

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _LiveInfoBanner(lastUpdated: state.lastUpdated),
                const SizedBox(height: 12),
                _RangeSelector(
                  selected: state.range,
                  onChanged: notifier.setRange,
                ),
                const SizedBox(height: 12),
                _KpiGrid(kpis: kpis),
                const SizedBox(height: 12),
                _ChartsSection(
                  mileage: state.mileageByRange,
                  statusShare: state.data.vehicleStatusShare,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveInfoBanner extends StatelessWidget {
  const _LiveInfoBanner({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Mock real-time updates every 10s')),
            Text(
              _formatTime(lastUpdated),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    final s = dateTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final DashboardRange selected;
  final void Function(DashboardRange value) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DashboardRange.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final range = DashboardRange.values[index];
          return ChoiceChip(
            label: Text(range.label),
            selected: selected == range,
            onSelected: (_) => onChanged(range),
          );
        },
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});

  final DashboardKpis kpis;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Total Vehicles',
        _formatCompact(kpis.totalVehicles),
        'Entire registered fleet',
        Icons.local_shipping_outlined,
        const Color(0xFF0284C7),
      ),
      (
        'Active Vehicles',
        _formatCompact(kpis.activeVehicles),
        'Currently on operation',
        Icons.check_circle_outline,
        const Color(0xFF16A34A),
      ),
      (
        'In Maintenance',
        _formatCompact(kpis.inMaintenance),
        'Service or repair queue',
        Icons.build_circle_outlined,
        const Color(0xFFF59E0B),
      ),
      (
        'Critical Alerts',
        _formatCompact(kpis.criticalAlerts),
        'Requires immediate action',
        Icons.warning_amber_rounded,
        const Color(0xFFDC2626),
      ),
      (
        'Avg Fuel Use',
        '${kpis.avgFuelConsumptionLPer100Km.toStringAsFixed(1)} L/100km',
        'Rolling operational average',
        Icons.local_gas_station_outlined,
        const Color(0xFF7C3AED),
      ),
    ];

    final crossAxisCount = Responsive.isDesktop(context)
        ? 3
        : Responsive.isTablet(context)
            ? 2
            : 1;

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: Responsive.isMobile(context) ? 2.7 : 2.2,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return KpiCard(
          title: item.$1,
          value: item.$2,
          subtitle: item.$3,
          icon: item.$4,
          color: item.$5,
        );
      },
    );
  }

  static String _formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return '$value';
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.mileage, required this.statusShare});

  final List<MileagePoint> mileage;
  final List<StatusShare> statusShare;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          _ChartCard(
            title: 'Mileage Trend',
            height: 290,
            child: DashboardMileageChart(points: mileage),
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: 'Vehicle Status Share',
            height: 290,
            child: DashboardStatusPieChart(items: statusShare),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ChartCard(
            title: 'Mileage Trend',
            height: 330,
            child: DashboardMileageChart(points: mileage),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChartCard(
            title: 'Vehicle Status Share',
            height: 330,
            child: DashboardStatusPieChart(items: statusShare),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.height,
    required this.child,
  });

  final String title;
  final double height;
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
            const SizedBox(height: 12),
            SizedBox(height: height, child: child),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 34),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
