import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionDetailScreen extends ConsumerStatefulWidget {
  const InspectionDetailScreen({super.key, required this.inspectionId});

  final String inspectionId;

  @override
  ConsumerState<InspectionDetailScreen> createState() =>
      _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends ConsumerState<InspectionDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionViewModelProvider);
    InspectionRecord? record;
    for (final item in state.items) {
      if (item.inspectionId == widget.inspectionId) {
        record = item;
        break;
      }
    }

    if (record == null) {
      return OpsShell(
        title: 'Inspection Detail',
        currentRoute: RoutePaths.inspections,
        child: const Center(child: Text('Inspection record not found.')),
      );
    }

    final resolvedRecord = record;

    return OpsShell(
      title: 'Inspection Detail',
      currentRoute: RoutePaths.inspections,
      actions: [
        FilledButton.icon(
          onPressed: () => context.push(
              RoutePaths.inspectionApprovalById(resolvedRecord.inspectionId)),
          icon: const Icon(Icons.approval_outlined),
          label: const Text('Open Approval'),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        children: [
          _HeaderCard(record: record),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Checklist Results'),
              Tab(text: 'Media Evidence'),
              Tab(text: 'Corrective Actions'),
              Tab(text: 'Approval'),
              Tab(text: 'Audit History'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(record: resolvedRecord),
                _ChecklistTab(record: resolvedRecord),
                _EvidenceTab(record: resolvedRecord),
                _CorrectiveActionsTab(record: resolvedRecord),
                _ApprovalTab(record: resolvedRecord),
                _AuditTab(record: resolvedRecord),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _chip('Inspection ID', record.inspectionId),
            _chip('Work Order', record.workOrder),
            _chip('Fleet', record.fleet),
            _chip('Driver', record.driver),
            _chip('Inspection Type', record.inspectionType.label),
            _chip('Result', record.overallResult.label),
            _chip('Approval Status', record.approvalStatus.label),
            _chip('Inspection Time', _fmtDateTime(record.inspectedAt)),
            _chip('Inspector', record.inspector),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F8),
        borderRadius: BorderRadius.circular(10),
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

  static String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Overview',
          rows: [
            _Pair('Work Order Reference', record.workOrder),
            _Pair('Linked Trip',
                record.linkedTrip.isEmpty ? '-' : record.linkedTrip),
            _Pair('Linked Fleet', record.fleet),
            _Pair('Linked Driver', record.driver),
            _Pair('Inspection Summary',
                '${record.failedItemsCount} failed item(s), ${record.criticalFailureCount} critical'),
            _Pair('Status Badges',
                '${record.status.label} • ${record.approvalStatus.label} • ${record.overallResult.label}'),
          ],
        ),
      ],
    );
  }
}

class _ChecklistTab extends StatelessWidget {
  const _ChecklistTab({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Item Name')),
            DataColumn(label: Text('Result')),
            DataColumn(label: Text('Remarks')),
            DataColumn(label: Text('Severity')),
            DataColumn(label: Text('Evidence Count')),
          ],
          rows: [
            for (final item in record.checklistItems)
              DataRow(
                color: item.passed
                    ? null
                    : WidgetStateProperty.all(const Color(0xFFFFF1F1)),
                cells: [
                  DataCell(Text(item.itemName)),
                  DataCell(
                    Text(
                      item.passed ? 'Pass' : 'Fail',
                      style: TextStyle(
                        color: item.passed
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(Text(item.remarks.isEmpty ? '-' : item.remarks)),
                  DataCell(Text(item.severity.label)),
                  DataCell(Text('${item.mediaCount}')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceTab extends StatelessWidget {
  const _EvidenceTab({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    final images =
        record.evidence.where((e) => e.type.toLowerCase() == 'image').toList();
    final videos =
        record.evidence.where((e) => e.type.toLowerCase() == 'video').toList();
    final docs = record.evidence
        .where((e) => e.type.toLowerCase() == 'document')
        .toList();

    return ListView(
      children: [
        _InfoCard(
          title: 'Media Evidence',
          rows: [
            _Pair('Image Thumbnails',
                images.isEmpty ? 'No images' : '${images.length} image(s)'),
            _Pair('Video List',
                videos.isEmpty ? 'No videos' : '${videos.length} video(s)'),
            _Pair('Document List',
                docs.isEmpty ? 'No documents' : '${docs.length} document(s)'),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evidence Timeline',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final evidence in record.evidence)
                  ListTile(
                    leading: Icon(
                      evidence.type == 'Image'
                          ? Icons.image_outlined
                          : evidence.type == 'Video'
                              ? Icons.videocam_outlined
                              : Icons.insert_drive_file_outlined,
                    ),
                    title: Text(evidence.name),
                    subtitle: Text(
                      'Uploaded by ${evidence.uploadedBy} at ${_fmtDateTime(evidence.uploadedAt)}',
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preview placeholder.')),
                        );
                      },
                      child: const Text('Preview'),
                    ),
                  ),
                if (record.evidence.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('No evidence records available.'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }
}

class _CorrectiveActionsTab extends StatelessWidget {
  const _CorrectiveActionsTab({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Issue Raised')),
            DataColumn(label: Text('Corrective Action Required')),
            DataColumn(label: Text('Assigned To')),
            DataColumn(label: Text('Due Date')),
            DataColumn(label: Text('Closure Note')),
            DataColumn(label: Text('Action Status')),
          ],
          rows: [
            for (final action in record.correctiveActions)
              DataRow(cells: [
                DataCell(Text(action.issueRaised)),
                DataCell(Text(action.actionRequired)),
                DataCell(Text(action.assignedTo)),
                DataCell(Text(_fmtDate(action.dueDate))),
                DataCell(Text(
                    action.closureNote.isEmpty ? '-' : action.closureNote)),
                DataCell(Text(action.status)),
              ]),
            if (record.correctiveActions.isEmpty)
              const DataRow(cells: [
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('No actions')),
              ]),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }
}

class _ApprovalTab extends StatelessWidget {
  const _ApprovalTab({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoCard(
          title: 'Approval',
          rows: [
            _Pair('Approval Notes',
                record.recommendation.isEmpty ? '-' : record.recommendation),
            _Pair('Reviewer Comments',
                record.reviewerName.isEmpty ? '-' : record.reviewerName),
            _Pair('Override Applied', record.overrideApplied ? 'Yes' : 'No'),
            _Pair('Override Reason',
                record.overrideReason.isEmpty ? '-' : record.overrideReason),
            _Pair('Dispatch Blocked', record.dispatchBlocked ? 'Yes' : 'No'),
            _Pair(
                'Next Inspection Date',
                record.nextInspectionDate == null
                    ? '-'
                    : _fmtDate(record.nextInspectionDate!)),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Approval History',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final item in record.approvalHistory)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_rounded),
                    title: Text('${item.decision} by ${item.reviewer}'),
                    subtitle: Text('${item.remarks}\n${_fmtDateTime(item.at)}'),
                  ),
                if (record.approvalHistory.isEmpty)
                  const Text('No approval history entries yet.'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                        RoutePaths.inspectionApprovalById(record.inspectionId)),
                    icon: const Icon(Icons.approval_outlined),
                    label: const Text('Approve/Reject Action'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  static String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }
}

class _AuditTab extends StatelessWidget {
  const _AuditTab({required this.record});

  final InspectionRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Audit History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final event in record.auditHistory)
            ListTile(
              leading: const Icon(Icons.timeline_outlined),
              title: Text(event.event),
              subtitle: Text('${event.actor} • ${_fmtDateTime(event.at)}'),
            ),
          if (record.auditHistory.isEmpty)
            const ListTile(
              title: Text('No audit events found.'),
            ),
        ],
      ),
    );
  }

  static String _fmtDateTime(DateTime dt) {
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
      margin: const EdgeInsets.only(bottom: 10),
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
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 10),
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
