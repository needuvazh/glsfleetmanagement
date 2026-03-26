import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';

class AssignmentListScreen extends ConsumerStatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  ConsumerState<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends ConsumerState<AssignmentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All'; // All, Unassigned, Partially Assigned, Assigned

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
      title: 'Fleet Assignment',
      currentRoute: RoutePaths.assignmentList,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final rows = _buildRows(data);
          final filteredRows = _applyFilters(rows);

          return Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildFilterPanel(),
              const SizedBox(height: 12),
              Expanded(
                child: Card(
                  child: filteredRows.isEmpty
                      ? const Center(child: Text('No work orders found for assignment.'))
                      : isMobile
                          ? _buildMobileList(filteredRows)
                          : _buildDesktopTable(filteredRows),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text('Assignment Registry',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('Track fleet and driver allocations across all open orders.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isMobile 
            ? Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search WO / Customer / Cargo',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(labelText: 'Assignment Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned')),
                      DropdownMenuItem(value: 'Partially Assigned', child: Text('Partially Assigned')),
                      DropdownMenuItem(value: 'Assigned', child: Text('Assigned')),
                    ],
                    onChanged: (v) => setState(() => _statusFilter = v!),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search WO / Customer / Cargo',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: const InputDecoration(labelText: 'Assignment Status'),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned')),
                        DropdownMenuItem(value: 'Partially Assigned', child: Text('Partially Assigned')),
                        DropdownMenuItem(value: 'Assigned', child: Text('Assigned')),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v!),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDesktopTable(List<_AssignmentRow> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text('WO NO')),
                  DataColumn(label: Text('CUSTOMER')),
                  DataColumn(label: Text('CARGO')),
                  DataColumn(label: Text('ROUTE')),
                  DataColumn(label: Text('REQ. VEHICLE')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: rows.map((row) => DataRow(
                  cells: [
                    DataCell(Text(row.woId, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(row.customer)),
                    DataCell(Text(row.cargo)),
                    DataCell(Text(row.route)),
                    DataCell(Text(row.requiredVehicle)),
                    DataCell(_buildStatusBadge(row.status)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.assignment_ind_outlined),
                        tooltip: 'Assign Resources',
                        onPressed: () => context.go(RoutePaths.resourceAssignmentById(row.woId)),
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileList(List<_AssignmentRow> rows) {
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = rows[index];
        return ListTile(
          title: Text(row.woId, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${row.customer} • ${row.cargo}'),
              Text(row.route),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(row.status),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => context.go(RoutePaths.resourceAssignmentById(row.woId)),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color textColor;
    switch (status) {
      case 'Assigned':
        color = const Color(0xFFE9F9EF);
        textColor = const Color(0xFF15803D);
        break;
      case 'Partially Assigned':
        color = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFB45309);
        break;
      default: // Unassigned
        color = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  List<_AssignmentRow> _buildRows(LogisticsUiState data) {
    return data.workOrders.map((wo) {
      final req = data.customerRequests.where((r) => r.enquiryNumber == wo.linkedEnquiryNumber).firstOrNull;
      
      String status = 'Unassigned';
      if (wo.assignedVehicleNo.isNotEmpty && wo.assignedDriverId.isNotEmpty) {
        status = 'Assigned';
      } else if (wo.assignedVehicleNo.isNotEmpty || wo.assignedDriverId.isNotEmpty) {
        status = 'Partially Assigned';
      }

      return _AssignmentRow(
        woId: wo.woId,
        customer: wo.customer,
        cargo: wo.cargo,
        route: wo.route,
        requiredVehicle: req?.requiredVehicleType ?? '-',
        status: status,
      );
    }).toList();
  }

  List<_AssignmentRow> _applyFilters(List<_AssignmentRow> rows) {
    final query = _searchController.text.toLowerCase();
    return rows.where((r) {
      if (_statusFilter != 'All' && r.status != _statusFilter) return false;
      if (query.isEmpty) return true;
      return r.woId.toLowerCase().contains(query) ||
          r.customer.toLowerCase().contains(query) ||
          r.cargo.toLowerCase().contains(query);
    }).toList();
  }
}

class _AssignmentRow {
  final String woId;
  final String customer;
  final String cargo;
  final String route;
  final String requiredVehicle;
  final String status;

  _AssignmentRow({
    required this.woId,
    required this.customer,
    required this.cargo,
    required this.route,
    required this.requiredVehicle,
    required this.status,
  });
}
