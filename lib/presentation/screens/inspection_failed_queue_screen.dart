import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionFailedQueueScreen extends ConsumerStatefulWidget {
  const InspectionFailedQueueScreen({super.key});

  @override
  ConsumerState<InspectionFailedQueueScreen> createState() =>
      _InspectionFailedQueueScreenState();
}

class _InspectionFailedQueueScreenState
    extends ConsumerState<InspectionFailedQueueScreen> {
  String _severityFilter = 'All';
  String _fleetFilter = 'All';
  String _driverFilter = 'All';
  String _woFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionViewModelProvider);
    final failed = state.items
        .where((item) => item.overallResult == InspectionResult.failed)
        .toList();

    final filtered = failed.where((item) {
      final maxSeverity = _maxSeverity(item);
      if (_severityFilter != 'All' && maxSeverity.label != _severityFilter) {
        return false;
      }
      if (_fleetFilter != 'All' && item.fleet != _fleetFilter) {
        return false;
      }
      if (_driverFilter != 'All' && item.driver != _driverFilter) {
        return false;
      }
      if (_woFilter != 'All' && item.workOrder != _woFilter) {
        return false;
      }
      return true;
    }).toList();

    final severityOptions = [
      'All',
      for (final s in InspectionFailureSeverity.values
          .where((s) => s != InspectionFailureSeverity.none))
        s.label,
    ];
    final fleetOptions = [
      'All',
      ...{for (final i in failed) i.fleet}.toList()..sort()
    ];
    final driverOptions = [
      'All',
      ...{for (final i in failed) i.driver}.toList()..sort()
    ];
    final woOptions = [
      'All',
      ...{for (final i in failed) i.workOrder}.toList()..sort()
    ];

    return OpsShell(
      title: 'Failed Inspection Queue',
      currentRoute: RoutePaths.inspectionFailedQueue,
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
                    label: 'Severity',
                    value: _severityFilter,
                    options: severityOptions,
                    onChanged: (v) => setState(() => _severityFilter = v),
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
                    label: 'Work Order',
                    value: _woFilter,
                    options: woOptions,
                    onChanged: (v) => setState(() => _woFilter = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Card(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No failed inspections for selected filters'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Inspection ID')),
                          DataColumn(label: Text('WO')),
                          DataColumn(label: Text('Fleet')),
                          DataColumn(label: Text('Driver')),
                          DataColumn(label: Text('Failed Item Count')),
                          DataColumn(label: Text('Criticality')),
                          DataColumn(label: Text('Corrective Action Status')),
                          DataColumn(label: Text('Responsible Person')),
                          DataColumn(label: Text('Due Date')),
                          DataColumn(label: Text('Dispatch Blocked')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: [
                          for (final item in filtered)
                            DataRow(cells: [
                              DataCell(Text(item.inspectionId)),
                              DataCell(Text(item.workOrder)),
                              DataCell(Text(item.fleet)),
                              DataCell(Text(item.driver)),
                              DataCell(Text('${item.failedItemsCount}')),
                              DataCell(Text(_maxSeverity(item).label)),
                              DataCell(Text(_correctiveStatus(item))),
                              DataCell(Text(_responsible(item))),
                              DataCell(Text(_dueDate(item))),
                              DataCell(
                                Text(
                                  item.dispatchBlocked ? 'Yes' : 'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: item.dispatchBlocked
                                        ? const Color(0xFFB91C1C)
                                        : const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                              DataCell(
                                Wrap(
                                  children: [
                                    IconButton(
                                      tooltip: 'Open Inspection',
                                      onPressed: () => context.push(
                                        RoutePaths.inspectionDetailById(
                                            item.inspectionId),
                                      ),
                                      icon:
                                          const Icon(Icons.open_in_new_rounded),
                                    ),
                                    IconButton(
                                      tooltip: 'Open Approval',
                                      onPressed: () => context.push(
                                        RoutePaths.inspectionApprovalById(
                                            item.inspectionId),
                                      ),
                                      icon: const Icon(Icons.approval_outlined),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InspectionFailureSeverity _maxSeverity(InspectionRecord record) {
    var level = InspectionFailureSeverity.none;
    for (final item in record.checklistItems) {
      if (!item.passed && item.severity.index > level.index) {
        level = item.severity;
      }
    }
    return level;
  }

  String _correctiveStatus(InspectionRecord record) {
    if (record.correctiveActions.isEmpty) {
      return 'Pending';
    }
    return record.correctiveActions.first.status;
  }

  String _responsible(InspectionRecord record) {
    if (record.correctiveActions.isEmpty) {
      return 'TBD';
    }
    return record.correctiveActions.first.assignedTo;
  }

  String _dueDate(InspectionRecord record) {
    if (record.correctiveActions.isEmpty) {
      return '-';
    }
    final due = record.correctiveActions.first.dueDate;
    final d = due.day.toString().padLeft(2, '0');
    final m = due.month.toString().padLeft(2, '0');
    return '$d/$m/${due.year}';
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
