import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/driver_detail_viewmodel.dart';
import '../widgets/ops_shell.dart';

class DriverDetailScreen extends ConsumerStatefulWidget {
  const DriverDetailScreen({
    super.key,
    required this.driverId,
    this.initialTab,
  });

  final String driverId;
  final String? initialTab;

  @override
  ConsumerState<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends ConsumerState<DriverDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    'summary',
    'license',
    'inspections',
    'assignments',
    'incidents',
    'media',
    'history',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: _initialTab(widget.initialTab),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(driverDetailProvider(widget.driverId));
    if (data == null) {
      return OpsShell(
        title: 'Driver Detail',
        currentRoute: RoutePaths.driverManagement,
        child: const Center(child: Text('Driver not found.')),
      );
    }

    return OpsShell(
      title: 'Driver Detail',
      currentRoute: RoutePaths.driverManagement,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _chip('Driver Code', data.driver.driverId),
                  _chip('Name', data.driver.name),
                  _chip('Phone', data.driver.phone),
                  _chip('Availability', data.driver.status),
                  _chip('Compliance', data.complianceStatus),
                  _chip('Current Trip', data.currentTrip),
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
              Tab(text: 'License/Documents'),
              Tab(text: 'Inspections'),
              Tab(text: 'Assignments'),
              Tab(text: 'Incidents'),
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
                  title: 'Summary',
                  rows: [
                    _Pair('Driver', data.driver.name),
                    _Pair('Phone', data.driver.phone),
                    _Pair('Experience', '${data.driver.experience} years'),
                    _Pair('Current Trip', data.currentTrip),
                  ],
                ),
                _InfoCard(
                  title: 'License & Documents',
                  rows: [
                    _Pair('License Number', data.driver.licenseNo),
                    _Pair('License Expiry', data.driver.expiryDate),
                    _Pair('DFMS Device', data.driver.dfmsDeviceId),
                    _Pair('Compliance Status', data.complianceStatus),
                  ],
                ),
                _InfoCard(
                  title: 'Inspections',
                  rows: [
                    _Pair('Inspection Links',
                        '${data.inspections.length} linked'),
                    _Pair(
                      'Latest Inspection',
                      data.inspections.isEmpty
                          ? '-'
                          : data.inspections.first.inspectionId,
                    ),
                    _Pair(
                      'Failed Inspections',
                      '${data.inspections.where((i) => i.overallResult.label == 'Failed').length}',
                    ),
                  ],
                ),
                Card(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Text('Assignments',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      for (final assign in data.assignments)
                        ListTile(
                          leading: const Icon(Icons.assignment_ind_outlined),
                          title: Text(assign),
                        ),
                      if (data.assignments.isEmpty)
                        const ListTile(title: Text('No active assignments.')),
                    ],
                  ),
                ),
                Card(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Text('Incidents',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      for (final incident in data.incidents)
                        ListTile(
                          leading: const Icon(Icons.report_problem_outlined),
                          title: Text(incident.title),
                          subtitle: Text(
                              '${incident.severity} • ${_fmtDateTime(incident.reportedAt)}'),
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
                              '${media.type} • ${media.source} • ${_fmtDateTime(media.uploadedAt)}'),
                        ),
                      if (data.media.isEmpty)
                        const ListTile(title: Text('No media linked.')),
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
      ),
    );
  }

  int _initialTab(String? key) {
    if (key == null) {
      return 0;
    }
    final idx = _tabs.indexOf(key.toLowerCase());
    return idx < 0 ? 0 : idx;
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
                style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
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
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 180,
                        child: Text(row.label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600))),
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
