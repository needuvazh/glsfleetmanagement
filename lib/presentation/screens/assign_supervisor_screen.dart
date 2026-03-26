import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';
import '../../routes/route_paths.dart';
import '../../domain/entities/logistics_flow.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../../core/utils/responsive.dart';

class AssignSupervisorScreen extends ConsumerStatefulWidget {
  final String workOrderId;

  const AssignSupervisorScreen({
    super.key,
    required this.workOrderId,
  });

  @override
  ConsumerState<AssignSupervisorScreen> createState() => _AssignSupervisorScreenState();
}

class _AssignSupervisorScreenState extends ConsumerState<AssignSupervisorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  final _dateController = TextEditingController();
  
  String? _selectedSupervisor;
  String? _selectedRegion;
  DateTime _assignmentDate = DateTime.now();

  final List<String> _supervisors = [
    'Ahmed Al-Hosni',
    'Salim Al-Balushi',
    'Khalid Al-Raisi',
    'Mohammed Al-Farsi',
  ];

  final List<String> _regions = [
    'Muscat - North',
    'Muscat - South',
    'Sohar Industrial',
    'Duqm Free Zone',
    'Salalah Port',
    'Nizwa Cluster',
  ];

  bool _isHydrated = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDateTime(_assignmentDate);
  }

  void _hydrateFromWorkOrder(WorkOrderFlowItem workOrder) {
    if (_isHydrated) return;
    if (workOrder.assignedSupervisor.isNotEmpty) {
      _selectedSupervisor = workOrder.assignedSupervisor;
      _selectedRegion = workOrder.supervisorRegion.isNotEmpty ? workOrder.supervisorRegion : null;
      _remarksController.text = workOrder.assignmentRemarks;
      if (workOrder.assignmentDate.isNotEmpty) {
        _dateController.text = workOrder.assignmentDate;
        // Try to parse Date back to _assignmentDate if needed for picker
      }
      _isHydrated = true;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _assignmentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_assignmentDate),
    );

    if (time != null) {
      setState(() {
        _assignmentDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        _dateController.text = _formatDateTime(_assignmentDate);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = ref.read(logisticsViewModelProvider.notifier);
    final result = await viewModel.assignSupervisor(
      workOrderId: widget.workOrderId,
      supervisorName: _selectedSupervisor!,
      region: _selectedRegion ?? '',
      assignmentDate: _dateController.text,
      remarks: _remarksController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final logisticsState = ref.watch(logisticsViewModelProvider);
    final workOrder = logisticsState.valueOrNull?.workOrders.where(
      (wo) => wo.woId == widget.workOrderId,
    ).firstOrNull ?? const WorkOrderFlowItem(
        woId: 'Unknown',
        customer: 'Unknown',
        route: 'Unknown',
        cargo: 'Unknown',
        status: 'Unknown',
    );

    _hydrateFromWorkOrder(workOrder);

    return OpsShell(
      title: 'Assign Supervisor',
      currentRoute: RoutePaths.woDelegation,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WO Summary Card
            _WorkOrderSummary(workOrder: workOrder),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  OpsSectionCard(
                    title: 'Delegation Details',
                    subtitle: 'Assign operational ownership to a supervisor',
                    icon: Icons.assignment_ind_outlined,
                    accent: Theme.of(context).primaryColor,
                    child: Column(
                      children: [
                        _buildRow(
                          DropdownButtonFormField<String>(
                            value: _selectedSupervisor,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Supervisor *',
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: _supervisors.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedSupervisor = val),
                            validator: (val) => val == null ? 'Required' : null,
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedRegion,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Region / Responsibility',
                              prefixIcon: Icon(Icons.map),
                            ),
                            items: _regions.map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedRegion = val),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRow(
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Assignment Date & Time',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: _pickDateTime,
                          ),
                          TextFormField(
                            controller: _remarksController,
                            decoration: const InputDecoration(
                              labelText: 'Assignment Remarks',
                              prefixIcon: Icon(Icons.comment),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.check),
                              label: const Text('SUBMIT'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _WorkOrderSummary extends StatelessWidget {
  final WorkOrderFlowItem? workOrder;

  const _WorkOrderSummary({required this.workOrder});

  @override
  Widget build(BuildContext context) {
    if (workOrder == null) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WORK ORDER ID',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      workOrder!.woId,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                _StatusChip(status: workOrder!.status),
              ],
            ),
            const Divider(height: 32),
            _SummaryRow(icon: Icons.business, label: 'Customer', value: workOrder!.customer),
            const SizedBox(height: 12),
            _SummaryRow(icon: Icons.route, label: 'Route', value: workOrder!.route),
            const SizedBox(height: 12),
            _SummaryRow(icon: Icons.inventory_2, label: 'Cargo', value: workOrder!.cargo),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'operationally owned': return Colors.green;
      case 'in transit': return Colors.orange;
      case 'completed': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
