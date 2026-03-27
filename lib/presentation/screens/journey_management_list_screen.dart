import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class JourneyManagementListScreen extends ConsumerStatefulWidget {
  const JourneyManagementListScreen({super.key});

  @override
  ConsumerState<JourneyManagementListScreen> createState() => _JourneyManagementListScreenState();
}

class _JourneyManagementListScreenState extends ConsumerState<JourneyManagementListScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Journey Management Plans',
      currentRoute: RoutePaths.journeyManagement,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${RoutePaths.journeyManagement}/new'),
          icon: const Icon(Icons.add),
          label: const Text('Create JMP'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final jmps = data.journeyPlans.where((jmp) {
            if (_statusFilter == 'All') return true;
            return jmp.status == _statusFilter;
          }).toList();

          final pendingWOs = data.workOrders.where((wo) {
            // "Eligible Work Order with Pending status" - meaning needs JMP
            final hasApprovedJmp = data.journeyPlans.any((jmp) => jmp.woId == wo.woId && jmp.status == 'Approved');
            return !hasApprovedJmp && wo.status.toLowerCase() != 'completed' && wo.status.toLowerCase() != 'cancelled';
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pendingWOs.isNotEmpty) ...[
                OpsSectionCard(
                  title: 'Pending Work Orders',
                  subtitle: '${pendingWOs.length} Work Order(s) require a Journey Management Plan',
                  icon: Icons.pending_actions,
                  accent: Colors.orange,
                  child: _buildPendingWOTable(pendingWOs),
                ),
                const SizedBox(height: 16),
              ],
              _buildFilters(),
              const SizedBox(height: 16),
              Expanded(
                child: OpsSectionCard(
                  title: 'JMP Registry',
                  subtitle: '${jmps.length} plan(s) found',
                  icon: Icons.alt_route,
                  accent: Colors.indigo,
                  child: jmps.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No Journey Plans found.'),
                          ),
                        )
                      : _buildTable(jmps),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Draft', 'Ready', 'Approved', 'Rejected'].map((status) {
          final isSelected = _statusFilter == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _statusFilter = status);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(List<JourneyManagementPlan> jmps) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 350),
        child: DataTable(
          showCheckboxColumn: false,
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          columns: const [
            DataColumn(label: Text('JMP No')),
            DataColumn(label: Text('WO No')),
            DataColumn(label: Text('Route')),
            DataColumn(label: Text('Risk')),
            DataColumn(label: Text('Approval Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: jmps.map((jmp) {
            return DataRow(
              onSelectChanged: (_) => context.go('${RoutePaths.journeyManagement}/${jmp.jmpId}'),
              cells: [
                DataCell(Text(jmp.jmpId, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(jmp.woId.isNotEmpty ? jmp.woId : '-')),
                DataCell(Text('${jmp.routeOrigin} -> ${jmp.routeDestination}')),
                DataCell(_RiskBadge(jmp.riskLevel)),
                DataCell(_StatusBadge(jmp.status)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => context.go('${RoutePaths.journeyManagement}/${jmp.jmpId}'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPendingWOTable(List<WorkOrderFlowItem> wos) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 350),
        child: DataTable(
          showCheckboxColumn: false,
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          columns: const [
            DataColumn(label: Text('WO No')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Route')),
            DataColumn(label: Text('Assignment')),
            DataColumn(label: Text('Action')),
          ],
          rows: wos.map((wo) {
            final hasAnyAssignment = wo.assignedVehicleNo.isNotEmpty || wo.assignedDriverId.isNotEmpty;
            return DataRow(
              cells: [
                DataCell(Text(wo.woId, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(wo.customer)),
                DataCell(Text(wo.route)),
                DataCell(Text(hasAnyAssignment ? 'Assigned' : 'Unassigned', style: TextStyle(color: hasAnyAssignment ? Colors.green : Colors.orange))),
                DataCell(
                  FilledButton.icon(
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create JMP'),
                    onPressed: () => context.go('${RoutePaths.journeyManagement}/new?woId=${wo.woId}'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String risk;
  const _RiskBadge(this.risk);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (risk == 'Low') color = Colors.green;
    if (risk == 'Medium') color = Colors.orange;
    if (risk == 'High') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        risk,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'Approved') color = Colors.green;
    if (status == 'Ready') color = Colors.blue;
    if (status == 'Rejected') color = Colors.red;
    if (status == 'Draft') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
