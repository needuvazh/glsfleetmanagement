import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../routes/route_paths.dart';
import '../widgets/ops_shell.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final List<_WorkOrderRow> _rows;
  String _statusFilter = 'All';
  String _customerFilter = 'All';
  String _routeFilter = 'All';
  String _priorityFilter = 'All';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _rows = _buildMockRows();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _filteredRows;
    final isMobile = Responsive.isMobile(context);

    return OpsShell(
      title: 'Work Orders',
      currentRoute: RoutePaths.workOrders,
      actions: [
        FilledButton.icon(
          onPressed: () => context.push(RoutePaths.createWorkOrder),
          icon: const Icon(Icons.add_task_outlined),
          label: const Text('Create New Work Order'),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterPanel(
            searchController: _searchController,
            statusFilter: _statusFilter,
            customerFilter: _customerFilter,
            routeFilter: _routeFilter,
            priorityFilter: _priorityFilter,
            dateRange: _dateRange,
            statusOptions: _optionsFrom(_rows.map((r) => r.status)),
            customerOptions: _optionsFrom(_rows.map((r) => r.customer)),
            routeOptions: _optionsFrom(_rows.map((r) => r.routeLabel)),
            priorityOptions: _optionsFrom(_rows.map((r) => r.priority)),
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
                        child: Text('No work orders match the current filters'),
                      )
                    : isMobile
                        ? _buildMobileList(filteredRows)
                        : _buildDesktopTable(filteredRows),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<_WorkOrderRow> rows) {
    return Column(
      children: [
        Row(
          children: [
            Text('Showing ${rows.length} work orders'),
            const Spacer(),
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
                columnSpacing: 18,
                headingRowHeight: 46,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 70,
                columns: const [
                  DataColumn(label: Text('WO Number')),
                  DataColumn(label: Text('Enquiry/Ref')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Cargo Type')),
                  DataColumn(label: Text('Origin')),
                  DataColumn(label: Text('Destination')),
                  DataColumn(label: Text('Planned Date')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assigned Fleet')),
                  DataColumn(label: Text('Assigned Driver')),
                  DataColumn(label: Text('Inspection Status')),
                  DataColumn(label: Text('Trip Status')),
                  DataColumn(label: Text('Last Updated')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: rows
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item.woNumber)),
                          DataCell(Text(item.enquiryReference)),
                          DataCell(Text(item.customer)),
                          DataCell(Text(item.cargoType)),
                          DataCell(Text(item.origin)),
                          DataCell(Text(item.destination)),
                          DataCell(Text(_formatDate(item.plannedDate))),
                          DataCell(
                            _statusChip(
                                item.priority, _priorityColor(item.priority)),
                          ),
                          DataCell(_statusChip(
                              item.status, _statusColor(item.status))),
                          DataCell(Text(item.assignedFleet)),
                          DataCell(Text(item.assignedDriver)),
                          DataCell(
                            _statusChip(
                              item.inspectionStatus,
                              _inspectionColor(item.inspectionStatus),
                            ),
                          ),
                          DataCell(_statusChip(
                              item.tripStatus, _tripColor(item.tripStatus))),
                          DataCell(Text(_formatDateTime(item.lastUpdated))),
                          DataCell(
                            _RowActions(
                              onOpen: () => _openWorkOrder(item),
                              onEdit: () =>
                                  _showPlaceholder('Edit ${item.woNumber}'),
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
                    Text(item.woNumber,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    _statusChip(item.status, _statusColor(item.status)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    '${item.customer} • ${item.origin} -> ${item.destination}'),
                const SizedBox(height: 6),
                Text(
                    'Fleet: ${item.assignedFleet} | Driver: ${item.assignedDriver}'),
                const SizedBox(height: 10),
                _RowActions(
                  compact: true,
                  onOpen: () => _openWorkOrder(item),
                  onEdit: () => _showPlaceholder('Edit ${item.woNumber}'),
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

  List<_WorkOrderRow> get _filteredRows {
    final query = _searchController.text.trim().toLowerCase();

    return _rows.where((row) {
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

  void _openAudit(_WorkOrderRow item) {
    context
        .push('${RoutePaths.workOrderDetailById(item.woNumber)}?tab=history');
  }

  void _duplicateWorkOrder(_WorkOrderRow item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Duplicated ${item.woNumber} with core and required document fields.',
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(_WorkOrderRow item) async {
    final reasonController = TextEditingController();
    final canceled = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Cancel ${item.woNumber}'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Cancellation reason *',
              hintText: 'Enter reason for cancellation',
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
        color: color.withOpacity(0.12),
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

  Color _inspectionColor(String status) {
    switch (status) {
      case 'Passed':
        return const Color(0xFF15803D);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Failed':
        return const Color(0xFFB91C1C);
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

  List<_WorkOrderRow> _buildMockRows() {
    final now = DateTime.now();
    return [
      _WorkOrderRow(
        woNumber: 'WO-24001',
        enquiryReference: 'ENQ-1012',
        customer: 'PDO Logistics',
        cargoType: 'Drilling Equipment',
        origin: 'Muscat Yard',
        destination: 'Fahud Site',
        plannedDate: now.add(const Duration(days: 1)),
        priority: 'High',
        status: 'Open',
        assignedFleet: 'TRK-201',
        assignedDriver: 'Ahmed Nasser',
        inspectionStatus: 'Pending',
        tripStatus: 'Not Started',
        lastUpdated: now.subtract(const Duration(minutes: 18)),
      ),
      _WorkOrderRow(
        woNumber: 'WO-24002',
        enquiryReference: 'ENQ-1014',
        customer: 'OQ Base Operations',
        cargoType: 'Chemical Drums',
        origin: 'Sohar Depot',
        destination: 'Nizwa Hub',
        plannedDate: now,
        priority: 'Medium',
        status: 'In Progress',
        assignedFleet: 'TRK-114',
        assignedDriver: 'Salim Rashid',
        inspectionStatus: 'Passed',
        tripStatus: 'Active',
        lastUpdated: now.subtract(const Duration(minutes: 6)),
      ),
      _WorkOrderRow(
        woNumber: 'WO-24003',
        enquiryReference: 'ENQ-1018',
        customer: 'Gulf Energy LLC',
        cargoType: 'Pipe Bundles',
        origin: 'Barka Yard',
        destination: 'Duqm Port',
        plannedDate: now.add(const Duration(days: 2)),
        priority: 'Low',
        status: 'Completed',
        assignedFleet: 'TRK-166',
        assignedDriver: 'Khalid Omar',
        inspectionStatus: 'Passed',
        tripStatus: 'Delivered',
        lastUpdated: now.subtract(const Duration(hours: 3)),
      ),
      _WorkOrderRow(
        woNumber: 'WO-24004',
        enquiryReference: 'ENQ-1022',
        customer: 'Oman Refining',
        cargoType: 'Fuel Additives',
        origin: 'Muscat Terminal',
        destination: 'Salalah Zone',
        plannedDate: now.add(const Duration(days: 3)),
        priority: 'High',
        status: 'In Progress',
        assignedFleet: 'TRK-309',
        assignedDriver: 'Majid Ali',
        inspectionStatus: 'Failed',
        tripStatus: 'Delayed',
        lastUpdated: now.subtract(const Duration(minutes: 45)),
      ),
      _WorkOrderRow(
        woNumber: 'WO-24005',
        enquiryReference: 'ENQ-1023',
        customer: 'Desert Well Services',
        cargoType: 'Rig Consumables',
        origin: 'Nizwa Warehouse',
        destination: 'Marmul Camp',
        plannedDate: now.add(const Duration(days: 1)),
        priority: 'Medium',
        status: 'Open',
        assignedFleet: 'TRK-410',
        assignedDriver: 'Rafiq Khan',
        inspectionStatus: 'Pending',
        tripStatus: 'Not Started',
        lastUpdated: now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
    ];
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search work orders',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            _FilterDropdown(
              label: 'Status',
              value: statusFilter,
              options: statusOptions,
              onChanged: onStatusChanged,
            ),
            _FilterDropdown(
              label: 'Customer',
              value: customerFilter,
              options: customerOptions,
              onChanged: onCustomerChanged,
            ),
            _FilterDropdown(
              label: 'Route',
              value: routeFilter,
              options: routeOptions,
              onChanged: onRouteChanged,
            ),
            _FilterDropdown(
              label: 'Priority',
              value: priorityFilter,
              options: priorityOptions,
              onChanged: onPriorityChanged,
            ),
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
      ),
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
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
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
