import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _statusFilter = 'All';
  String _customerFilter = 'All';
  String _routeFilter = 'All';
  String _priorityFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Work Orders',
      currentRoute: RoutePaths.workOrders,
      actions: const [],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = _rowsFromWorkOrders(data.workOrders, data.lastUpdated);
          final filteredRows = _filteredRows(rows);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isMobile
                      ? SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                context.push(RoutePaths.createWorkOrder),
                            icon: const Icon(Icons.add_task_outlined),
                            label: const Text('Create New Work Order'),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              'Work Order Register',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.push(RoutePaths.createWorkOrder),
                              icon: const Icon(Icons.add_task_outlined),
                              label: const Text('Create New Work Order'),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              _FilterPanel(
                searchController: _searchController,
                statusFilter: _statusFilter,
                customerFilter: _customerFilter,
                routeFilter: _routeFilter,
                priorityFilter: _priorityFilter,
                dateRange: _dateRange,
                statusOptions: _optionsFrom(rows.map((r) => r.status)),
                customerOptions: _optionsFrom(rows.map((r) => r.customer)),
                routeOptions: _optionsFrom(rows.map((r) => r.routeLabel)),
                priorityOptions: _optionsFrom(rows.map((r) => r.priority)),
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onCustomerChanged: (v) => setState(() => _customerFilter = v),
                onRouteChanged: (v) => setState(() => _routeFilter = v),
                onPriorityChanged: (v) => setState(() => _priorityFilter = v),
                onDateRangeTap: _pickDateRange,
                onClearAll: _resetFilters,
                onExportTap: _showExportPlaceholder,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: filteredRows.isEmpty
                        ? const Center(
                            child: Text(
                                'No work orders match the current filters'),
                          )
                        : isMobile
                            ? _buildMobileList(filteredRows)
                            : _buildDesktopTable(filteredRows),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopTable(List<_WorkOrderRow> rows) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: [
            Text('Showing ${rows.length} work orders'),
            Text(
              'Last synced ${_formatDateTime(rows.first.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 28,
                horizontalMargin: 16,
                headingRowHeight: 46,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('WO Number')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Route')),
                  DataColumn(label: Text('Planned Date')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Trip Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: rows
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item.woNumber)),
                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Text(
                                item.customer,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(
                                '${item.origin} -> ${item.destination}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(_formatDate(item.plannedDate))),
                          DataCell(
                            _statusChip(
                                item.priority, _priorityColor(item.priority)),
                          ),
                          DataCell(_statusChip(
                              item.status, _statusColor(item.status))),
                          DataCell(_statusChip(
                              item.tripStatus, _tripColor(item.tripStatus))),
                          DataCell(
                            _RowActions(
                              onOpen: () => _openWorkOrder(item),
                              onEdit: () => _openEditWorkOrder(item),
                              onDuplicate: () => _duplicateWorkOrder(item),
                              onCancel: () => _showCancelDialog(item),
                              onAudit: () => _openAudit(item),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(List<_WorkOrderRow> rows) {
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = rows[index];
        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.woNumber,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusChip(item.status, _statusColor(item.status)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.customer} • ${item.origin} -> ${item.destination}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                    'Fleet: ${item.assignedFleet} | Driver: ${item.assignedDriver}'),
                const SizedBox(height: 10),
                _RowActions(
                  compact: true,
                  onOpen: () => _openWorkOrder(item),
                  onEdit: () => _openEditWorkOrder(item),
                  onDuplicate: () => _duplicateWorkOrder(item),
                  onCancel: () => _showCancelDialog(item),
                  onAudit: () => _openAudit(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_WorkOrderRow> _filteredRows(List<_WorkOrderRow> rows) {
    final query = _searchController.text.trim().toLowerCase();

    return rows.where((row) {
      if (_statusFilter != 'All' && row.status != _statusFilter) {
        return false;
      }
      if (_customerFilter != 'All' && row.customer != _customerFilter) {
        return false;
      }
      if (_routeFilter != 'All' && row.routeLabel != _routeFilter) {
        return false;
      }
      if (_priorityFilter != 'All' && row.priority != _priorityFilter) {
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
        if (row.plannedDate.isBefore(start) || row.plannedDate.isAfter(end)) {
          return false;
        }
      }
      if (query.isEmpty) {
        return true;
      }

      final text = [
        row.woNumber,
        row.enquiryReference,
        row.customer,
        row.cargoType,
        row.origin,
        row.destination,
        row.assignedFleet,
        row.assignedDriver,
        row.status,
      ].join(' ').toLowerCase();
      return text.contains(query);
    }).toList();
  }

  List<_WorkOrderRow> _rowsFromWorkOrders(
    List<WorkOrderFlowItem> workOrders,
    DateTime lastUpdated,
  ) {
    final now = DateTime.now();
    final rows = [
      for (final item in workOrders)
        _WorkOrderRow(
          woNumber: item.woId,
          enquiryReference: item.linkedEnquiryNumber.isNotEmpty
              ? item.linkedEnquiryNumber
              : item.linkedQuotationRef,
          customer: item.customer,
          cargoType: item.cargo,
          origin: _routeOrigin(item.route),
          destination: _routeDestination(item.route),
          plannedDate: _parseDate(item.serviceStartDate) ?? now,
          priority: 'Medium',
          status: item.status,
          assignedFleet: '-',
          assignedDriver: '-',
          inspectionStatus: 'Pending',
          tripStatus: _tripFromStatus(item.status),
          lastUpdated: lastUpdated,
        ),
    ];
    rows.sort((a, b) => a.plannedDate.compareTo(b.plannedDate));
    return rows;
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.trim());
  }

  String _routeOrigin(String route) {
    final parts = route.split('->');
    if (parts.isEmpty) {
      return route;
    }
    return parts.first.trim();
  }

  String _routeDestination(String route) {
    final parts = route.split('->');
    if (parts.length < 2) {
      return route;
    }
    return parts.last.trim();
  }

  String _tripFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'ready for allocation':
        return 'Not Started';
      case 'assigned':
      case 'in progress':
        return 'Active';
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Delayed';
      default:
        return 'Not Started';
    }
  }

  List<String> _optionsFrom(Iterable<String> source) {
    final values = source.toSet().toList()..sort();
    return ['All', ...values];
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _resetFilters() {
    setState(() {
      _statusFilter = 'All';
      _customerFilter = 'All';
      _routeFilter = 'All';
      _priorityFilter = 'All';
      _dateRange = null;
      _searchController.clear();
    });
  }

  void _showExportPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Export will be connected to reporting service.')),
    );
  }

  void _openWorkOrder(_WorkOrderRow item) {
    context.push(RoutePaths.workOrderDetailById(item.woNumber));
  }

  void _openEditWorkOrder(_WorkOrderRow item) {
    context.push(RoutePaths.createWorkOrder);
  }

  void _openAudit(_WorkOrderRow item) {
    context
        .push('${RoutePaths.workOrderDetailById(item.woNumber)}?tab=history');
  }

  void _duplicateWorkOrder(_WorkOrderRow item) {
    final message = ref
        .read(logisticsViewModelProvider.notifier)
        .duplicateWorkOrder(item.woNumber);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showCancelDialog(_WorkOrderRow item) async {
    final reasonController = TextEditingController();
    String? inlineError;
    final canceled = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isMobile = MediaQuery.of(dialogContext).size.width < 700;
        final dialogWidth = isMobile ? 420.0 : 560.0;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Cancel ${item.woNumber}'),
              content: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please provide a mandatory reason for cancellation. This will be recorded in the audit trail.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Cancellation reason *',
                        hintText: 'Enter reason for cancellation',
                        errorText: inlineError,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Close'),
                ),
                FilledButton(
                  onPressed: () {
                    if (reasonController.text.trim().isEmpty) {
                      setDialogState(() {
                        inlineError = 'Cancellation reason is required.';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Confirm Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (canceled == true) {
      _showPlaceholder('${item.woNumber} canceled with reason recorded.');
    } else if (reasonController.text.trim().isEmpty) {
      _showPlaceholder('Cancellation reason is required.');
    }

    reasonController.dispose();
  }

  void _showPlaceholder(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${_formatDate(value)} $hour:$minute';
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return const Color(0xFF2563EB);
      case 'In Progress':
        return const Color(0xFFD97706);
      case 'Completed':
        return const Color(0xFF15803D);
      case 'Cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFDC2626);
      case 'Medium':
        return const Color(0xFFD97706);
      case 'Low':
        return const Color(0xFF0369A1);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _tripColor(String status) {
    switch (status) {
      case 'Not Started':
        return const Color(0xFF2563EB);
      case 'Active':
        return const Color(0xFF7C3AED);
      case 'Delayed':
        return const Color(0xFFB45309);
      case 'Delivered':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF475569);
    }
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.searchController,
    required this.statusFilter,
    required this.customerFilter,
    required this.routeFilter,
    required this.priorityFilter,
    required this.dateRange,
    required this.statusOptions,
    required this.customerOptions,
    required this.routeOptions,
    required this.priorityOptions,
    required this.onStatusChanged,
    required this.onCustomerChanged,
    required this.onRouteChanged,
    required this.onPriorityChanged,
    required this.onDateRangeTap,
    required this.onClearAll,
    required this.onExportTap,
  });

  final TextEditingController searchController;
  final String statusFilter;
  final String customerFilter;
  final String routeFilter;
  final String priorityFilter;
  final DateTimeRange? dateRange;
  final List<String> statusOptions;
  final List<String> customerOptions;
  final List<String> routeOptions;
  final List<String> priorityOptions;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onCustomerChanged;
  final ValueChanged<String> onRouteChanged;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onDateRangeTap;
  final VoidCallback onClearAll;
  final VoidCallback onExportTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 980;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: compact ? _buildCompactFilterLayout() : _buildWideFilterLayout(),
      ),
    );
  }

  Widget _buildWideFilterLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search work orders',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Status',
                value: statusFilter,
                options: statusOptions,
                onChanged: onStatusChanged,
                width: null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Customer',
                value: customerFilter,
                options: customerOptions,
                onChanged: onCustomerChanged,
                width: null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Route',
                value: routeFilter,
                options: routeOptions,
                onChanged: onRouteChanged,
                width: null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Priority',
                value: priorityFilter,
                options: priorityOptions,
                onChanged: onPriorityChanged,
                width: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onDateRangeTap,
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                dateRange == null
                    ? 'Filter by Date'
                    : '${_fmt(dateRange!.start)} - ${_fmt(dateRange!.end)}',
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onExportTap,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactFilterLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search work orders',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Status',
                value: statusFilter,
                options: statusOptions,
                onChanged: onStatusChanged,
                width: null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDropdown(
                label: 'Priority',
                value: priorityFilter,
                options: priorityOptions,
                onChanged: onPriorityChanged,
                width: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FilterDropdown(
          label: 'Customer',
          value: customerFilter,
          options: customerOptions,
          onChanged: onCustomerChanged,
          width: null,
        ),
        const SizedBox(height: 10),
        _FilterDropdown(
          label: 'Route',
          value: routeFilter,
          options: routeOptions,
          onChanged: onRouteChanged,
          width: null,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onDateRangeTap,
              icon: const Icon(Icons.date_range_outlined),
              label: Text(
                dateRange == null
                    ? 'Filter by Date'
                    : '${_fmt(dateRange!.start)} - ${_fmt(dateRange!.end)}',
              ),
            ),
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
            ),
            OutlinedButton.icon(
              onPressed: onExportTap,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export'),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 170,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onCancel,
    required this.onAudit,
    this.compact = false,
  });

  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onCancel;
  final VoidCallback onAudit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Wrap(
        spacing: 6,
        children: [
          TextButton(onPressed: onOpen, child: const Text('Open')),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
          TextButton(onPressed: onDuplicate, child: const Text('Duplicate')),
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
          TextButton(onPressed: onAudit, child: const Text('Audit')),
        ],
      );
    }

    return Wrap(
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Open',
          onPressed: onOpen,
          icon: const Icon(Icons.open_in_new_rounded),
        ),
        IconButton(
          tooltip: 'Edit',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Duplicate',
          onPressed: onDuplicate,
          icon: const Icon(Icons.copy_all_outlined),
        ),
        IconButton(
          tooltip: 'Cancel',
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined),
        ),
        IconButton(
          tooltip: 'View Audit',
          onPressed: onAudit,
          icon: const Icon(Icons.history_rounded),
        ),
      ],
    );
  }
}

class _WorkOrderRow {
  const _WorkOrderRow({
    required this.woNumber,
    required this.enquiryReference,
    required this.customer,
    required this.cargoType,
    required this.origin,
    required this.destination,
    required this.plannedDate,
    required this.priority,
    required this.status,
    required this.assignedFleet,
    required this.assignedDriver,
    required this.inspectionStatus,
    required this.tripStatus,
    required this.lastUpdated,
  });

  final String woNumber;
  final String enquiryReference;
  final String customer;
  final String cargoType;
  final String origin;
  final String destination;
  final DateTime plannedDate;
  final String priority;
  final String status;
  final String assignedFleet;
  final String assignedDriver;
  final String inspectionStatus;
  final String tripStatus;
  final DateTime lastUpdated;

  String get routeLabel => '$origin -> $destination';
}
