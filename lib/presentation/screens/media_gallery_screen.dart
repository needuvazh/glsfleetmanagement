import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/media_evidence_viewmodel.dart';
import '../widgets/ops_shell.dart';

class MediaGalleryScreen extends ConsumerStatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  ConsumerState<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends ConsumerState<MediaGalleryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _workOrderFilter = 'All';
  String _inspectionFilter = 'All';
  String _tripFilter = 'All';
  String _fleetFilter = 'All';
  String _driverFilter = 'All';
  String _mediaTypeFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mediaEvidenceProvider);
    final allItems = state.items;

    final workOrderOptions = _optionsFrom(allItems.map((e) => e.workOrder));
    final inspectionOptions = _optionsFrom(allItems.map((e) => e.inspection));
    final tripOptions = _optionsFrom(allItems.map((e) => e.trip));
    final fleetOptions = _optionsFrom(allItems.map((e) => e.fleet));
    final driverOptions = _optionsFrom(allItems.map((e) => e.driver));

    return OpsShell(
      title: 'Media Gallery',
      currentRoute: RoutePaths.mediaGallery,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Drop(
                    label: 'Work Order',
                    value: _workOrderFilter,
                    options: workOrderOptions,
                    onChanged: (v) => setState(() => _workOrderFilter = v),
                  ),
                  _Drop(
                    label: 'Inspection',
                    value: _inspectionFilter,
                    options: inspectionOptions,
                    onChanged: (v) => setState(() => _inspectionFilter = v),
                  ),
                  _Drop(
                    label: 'Trip',
                    value: _tripFilter,
                    options: tripOptions,
                    onChanged: (v) => setState(() => _tripFilter = v),
                  ),
                  _Drop(
                    label: 'Fleet',
                    value: _fleetFilter,
                    options: fleetOptions,
                    onChanged: (v) => setState(() => _fleetFilter = v),
                  ),
                  _Drop(
                    label: 'Driver',
                    value: _driverFilter,
                    options: driverOptions,
                    onChanged: (v) => setState(() => _driverFilter = v),
                  ),
                  _Drop(
                    label: 'Media Type',
                    value: _mediaTypeFilter,
                    options: const ['All', 'Photo', 'Video', 'Document'],
                    onChanged: (v) => setState(() => _mediaTypeFilter = v),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(
                      _dateRange == null
                          ? 'Filter by Date'
                          : '${_fmtDate(_dateRange!.start)} - ${_fmtDate(_dateRange!.end)}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _workOrderFilter = 'All';
                        _inspectionFilter = 'All';
                        _tripFilter = 'All';
                        _fleetFilter = 'All';
                        _driverFilter = 'All';
                        _mediaTypeFilter = 'All';
                        _dateRange = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Photos'),
              Tab(text: 'Videos'),
              Tab(text: 'Documents'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTable(
                  context,
                  _filtered(allItems, MediaEvidenceType.photo),
                ),
                _buildTable(
                  context,
                  _filtered(allItems, MediaEvidenceType.video),
                ),
                _buildTable(
                  context,
                  _filtered(allItems, MediaEvidenceType.document),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<MediaEvidenceItem> items) {
    if (items.isEmpty) {
      return const Card(
        child: Center(
            child: Text('No media evidence found for selected filters.')),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Thumbnail')),
            DataColumn(label: Text('File Name / Label')),
            DataColumn(label: Text('Linked Module')),
            DataColumn(label: Text('Linked Record')),
            DataColumn(label: Text('Captured By')),
            DataColumn(label: Text('Captured At')),
            DataColumn(label: Text('Remarks')),
            DataColumn(label: Text('Action')),
          ],
          rows: [
            for (final item in items)
              DataRow(cells: [
                DataCell(_thumb(item.type)),
                DataCell(Text(item.fileName)),
                DataCell(Text(item.linkedModule)),
                DataCell(Text(item.linkedRecord)),
                DataCell(Text(item.capturedBy)),
                DataCell(Text(_fmtDateTime(item.capturedAt))),
                DataCell(
                  SizedBox(
                    width: 260,
                    child: Text(
                      item.remarks,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    tooltip: 'Open Preview',
                    onPressed: () => context.push(
                      RoutePaths.mediaPreviewById(item.id),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }

  List<MediaEvidenceItem> _filtered(
    List<MediaEvidenceItem> source,
    MediaEvidenceType tabType,
  ) {
    return source.where((item) {
      if (item.type != tabType) {
        return false;
      }
      if (_workOrderFilter != 'All' && item.workOrder != _workOrderFilter) {
        return false;
      }
      if (_inspectionFilter != 'All' && item.inspection != _inspectionFilter) {
        return false;
      }
      if (_tripFilter != 'All' && item.trip != _tripFilter) {
        return false;
      }
      if (_fleetFilter != 'All' && item.fleet != _fleetFilter) {
        return false;
      }
      if (_driverFilter != 'All' && item.driver != _driverFilter) {
        return false;
      }
      if (_mediaTypeFilter != 'All' && item.type.label != _mediaTypeFilter) {
        return false;
      }
      if (_dateRange != null) {
        final start = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final end = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
          23,
          59,
          59,
        );
        if (item.capturedAt.isBefore(start) || item.capturedAt.isAfter(end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<String> _optionsFrom(Iterable<String?> values) {
    final set = <String>{};
    for (final v in values) {
      if (v != null && v.isNotEmpty) {
        set.add(v);
      }
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Widget _thumb(MediaEvidenceType type) {
    final icon = switch (type) {
      MediaEvidenceType.photo => Icons.image_outlined,
      MediaEvidenceType.video => Icons.videocam_outlined,
      MediaEvidenceType.document => Icons.insert_drive_file_outlined,
    };
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF3F5F8),
      ),
      child: Icon(icon, size: 18),
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

class _Drop extends StatelessWidget {
  const _Drop({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
