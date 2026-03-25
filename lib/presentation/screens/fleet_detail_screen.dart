import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fleet.dart';
import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/fleet_detail_viewmodel.dart';
import '../viewmodels/fleet_viewmodel.dart';
import '../widgets/ops_shell.dart';

class FleetDetailScreen extends ConsumerStatefulWidget {
  const FleetDetailScreen({
    super.key,
    required this.fleetId,
    this.initialTab,
  });

  final String fleetId;
  final String? initialTab;

  @override
  ConsumerState<FleetDetailScreen> createState() => _FleetDetailScreenState();
}

class _FleetDetailScreenState extends ConsumerState<FleetDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabKeys = [
    'summary',
    'compliance',
    'inspections',
    'trips',
    'media',
    'history',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: _tabIndex(widget.initialTab),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fleetAsync = ref.watch(fleetViewModelProvider);

    return OpsShell(
      title: 'Fleet Detail',
      currentRoute: RoutePaths.fleetManagement,
      child: fleetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (_) {
          final data = ref.watch(fleetDetailProvider(widget.fleetId));
          if (data == null) {
            return const Center(child: Text('Fleet not found.'));
          }

          final passCount = data.inspections
              .where((i) => i.overallResult == InspectionResult.passed)
              .length;
          final failCount = data.inspections
              .where((i) => i.overallResult == InspectionResult.failed)
              .length;

          return Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _chip('Fleet', data.fleet.vehicleNumber),
                      _chip('Type', data.fleet.type),
                      _chip('Current Status', data.fleet.status.label),
                      _chip('Driver', data.fleet.driver),
                      _chip('Linked Inspections', '${data.inspections.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Summary'),
                  Tab(text: 'Compliance'),
                  Tab(text: 'Inspections'),
                  Tab(text: 'Trips'),
                  Tab(text: 'Media'),
                  Tab(text: 'History'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InfoCard(
                      title: 'Vehicle Summary',
                      rows: [
                        _Pair('Vehicle Info',
                            '${data.fleet.vehicleNumber} (${data.fleet.type})'),
                        _Pair('Ownership Type', data.ownershipType),
                        _Pair('Registration', data.registration),
                        _Pair('Current Status', data.fleet.status.label),
                      ],
                    ),
                    _InfoCard(
                      title: 'Compliance',
                      rows: [
                        _Pair('Insurance', _fmtDate(data.insuranceExpiry)),
                        _Pair('Permit', _fmtDate(data.permitExpiry)),
                        _Pair(
                            'Inspection Due', _fmtDate(data.inspectionDueDate)),
                        _Pair('Expiry Warnings', data.expiryWarnings),
                      ],
                    ),
                    _InfoCard(
                      title: 'Inspections',
                      rows: [
                        _Pair('All Linked Inspections',
                            '${data.inspections.length}'),
                        _Pair('Pass / Fail Count', '$passCount / $failCount'),
                        _Pair(
                            'Recent Inspection',
                            data.inspections.isEmpty
                                ? '-'
                                : data.inspections.first.inspectionId),
                      ],
                    ),
                    Card(
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Text('Trips',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final trip in data.trips)
                            ListTile(
                              leading: const Icon(Icons.alt_route_outlined),
                              title: Text(trip.tripId),
                              subtitle: Text(
                                  '${trip.status} • ${_fmtDateTime(trip.at)}'),
                            ),
                        ],
                      ),
                    ),
                    Card(
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Text('Media',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final media in data.media)
                            ListTile(
                              leading: Icon(
                                media.type == 'Video'
                                    ? Icons.videocam_outlined
                                    : media.type == 'Document'
                                        ? Icons.insert_drive_file_outlined
                                        : Icons.image_outlined,
                              ),
                              title: Text(media.name),
                              subtitle: Text(
                                  '${media.type} • ${media.uploader} • ${_fmtDateTime(media.uploadedAt)}'),
                            ),
                          if (data.media.isEmpty)
                            const ListTile(
                                title: Text('No media evidence found.')),
                        ],
                      ),
                    ),
                    Card(
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Text('History',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final event in data.history)
                            ListTile(
                              leading: const Icon(Icons.history_outlined),
                              title: Text(event.event),
                              subtitle: Text(
                                  '${event.actor} • ${_fmtDateTime(event.at)}'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _tabIndex(String? key) {
    if (key == null) {
      return 0;
    }
    final i = _tabKeys.indexOf(key.toLowerCase());
    return i < 0 ? 0 : i;
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF3F5F8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF111827), fontSize: 12),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_Pair> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
                      child: Text(
                        row.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pair {
  const _Pair(this.label, this.value);

  final String label;
  final String value;
}
