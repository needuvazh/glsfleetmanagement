import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionListScreen extends ConsumerWidget {
  const InspectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionViewModelProvider);
    final vm = ref.read(inspectionViewModelProvider.notifier);

    final filtered = state.filteredItems;
    final statusOptions = [
      'All',
      for (final value in InspectionStatus.values) value.label,
    ];
    final inspectorOptions = [
      'All',
      ...{for (final item in state.items) item.inspector}.toList()..sort(),
    ];

    return OpsShell(
      title: 'Inspections',
      currentRoute: RoutePaths.inspections,
      actions: [
        FilledButton.icon(
          onPressed: () => context.push(RoutePaths.inspectionCreate),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Create Inspection'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Export will be connected to reporting service.')),
            );
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('Export'),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 240,
                    child: TextField(
                      onChanged: vm.setQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search WO, fleet, driver',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  _FilterDrop(
                    label: 'Status',
                    value: state.statusFilter,
                    options: statusOptions,
                    onChanged: vm.setStatusFilter,
                  ),
                  _FilterDrop(
                    label: 'Inspector',
                    value: state.inspectorFilter,
                    options: inspectorOptions,
                    onChanged: vm.setInspectorFilter,
                  ),
                  _FilterDrop(
                    label: 'Pass/Fail',
                    value: state.resultFilter,
                    options: const ['All', 'Passed', 'Failed'],
                    onChanged: vm.setResultFilter,
                  ),
                  FilterChip(
                    selected: state.pendingApprovalOnly,
                    onSelected: vm.setPendingApprovalOnly,
                    label: const Text('Pending Approval Only'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 3),
                        lastDate: DateTime(now.year + 1),
                        initialDateRange: state.dateRange,
                      );
                      vm.setDateRange(picked);
                    },
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(
                      state.dateRange == null
                          ? 'Filter by Date'
                          : '${_fmtDate(state.dateRange!.start)} - ${_fmtDate(state.dateRange!.end)}',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      vm.setQuery('');
                      vm.setStatusFilter('All');
                      vm.setInspectorFilter('All');
                      vm.setResultFilter('All');
                      vm.setPendingApprovalOnly(false);
                      vm.setDateRange(null);
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
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
                      child: Text('No inspections match current filters'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Inspection ID')),
                            DataColumn(label: Text('Inspection Type')),
                            DataColumn(label: Text('Work Order')),
                            DataColumn(label: Text('Fleet')),
                            DataColumn(label: Text('Trailer')),
                            DataColumn(label: Text('Driver')),
                            DataColumn(label: Text('Inspector')),
                            DataColumn(label: Text('Inspected At')),
                            DataColumn(label: Text('Overall Result')),
                            DataColumn(label: Text('Approval Status')),
                            DataColumn(label: Text('Media Count')),
                            DataColumn(label: Text('Last Updated')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: [
                            for (final item in filtered)
                              DataRow(
                                cells: [
                                  DataCell(Text(item.inspectionId)),
                                  DataCell(Text(item.inspectionType.label)),
                                  DataCell(Text(item.workOrder)),
                                  DataCell(Text(item.fleet)),
                                  DataCell(Text(item.trailer)),
                                  DataCell(Text(item.driver)),
                                  DataCell(Text(item.inspector)),
                                  DataCell(
                                      Text(_fmtDateTime(item.inspectedAt))),
                                  DataCell(_resultChip(item.overallResult)),
                                  DataCell(_approvalChip(item.approvalStatus)),
                                  DataCell(Text('${item.mediaCount}')),
                                  DataCell(
                                      Text(_fmtDateTime(item.lastUpdated))),
                                  DataCell(
                                    IconButton(
                                      tooltip: 'Open Inspection Detail',
                                      onPressed: () => context.push(
                                        RoutePaths.inspectionDetailById(
                                          item.inspectionId,
                                        ),
                                      ),
                                      icon:
                                          const Icon(Icons.open_in_new_rounded),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }

  static String _fmtDateTime(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '${_fmtDate(value)} $h:$m';
  }

  Widget _resultChip(InspectionResult result) {
    final isPass = result == InspectionResult.passed;
    final color = isPass ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    return _chip(result.label, color);
  }

  Widget _approvalChip(InspectionApprovalStatus status) {
    final color = switch (status) {
      InspectionApprovalStatus.approved => const Color(0xFF15803D),
      InspectionApprovalStatus.pending => const Color(0xFFD97706),
      InspectionApprovalStatus.rejected => const Color(0xFFB91C1C),
      InspectionApprovalStatus.sentBack => const Color(0xFF7C3AED),
      InspectionApprovalStatus.none => const Color(0xFF475569),
    };
    return _chip(status.label, color);
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _FilterDrop extends StatelessWidget {
  const _FilterDrop({
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
