import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/user.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionApprovalScreen extends ConsumerStatefulWidget {
  const InspectionApprovalScreen({super.key, required this.inspectionId});

  final String inspectionId;

  @override
  ConsumerState<InspectionApprovalScreen> createState() =>
      _InspectionApprovalScreenState();
}

class _InspectionApprovalScreenState
    extends ConsumerState<InspectionApprovalScreen> {
  final _remarksController = TextEditingController();
  final _actionNoteController = TextEditingController();
  final _overrideReasonController = TextEditingController();
  DateTime? _nextInspectionDate;

  @override
  void dispose() {
    _remarksController.dispose();
    _actionNoteController.dispose();
    _overrideReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(inspectionViewModelProvider.notifier);
    final record = vm.byId(widget.inspectionId);
    final role = ref.watch(authViewModelProvider).valueOrNull?.user?.role;

    if (record == null) {
      return OpsShell(
        title: 'Inspection Approval',
        currentRoute: RoutePaths.inspections,
        child: const Center(child: Text('Inspection not found.')),
      );
    }

    final canOverride = role == UserRole.admin || role == UserRole.compliance;

    return OpsShell(
      title: 'Inspection Approval',
      currentRoute: RoutePaths.inspections,
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspection Summary Panel',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _pair('Inspection Result', record.overallResult.label),
                  _pair('Failed Items Count', '${record.failedItemsCount}'),
                  _pair('Critical Failure Count',
                      '${record.criticalFailureCount}'),
                  _pair('Media Available', '${record.mediaCount}'),
                  _pair('Linked WO/Fleet/Driver',
                      '${record.workOrder} / ${record.fleet} / ${record.driver}'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: record.dispatchBlocked
                          ? const Color(0xFFFFF1F1)
                          : const Color(0xFFE9F9EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      record.dispatchBlocked
                          ? 'Dispatch is blocked due to critical failures.'
                          : 'Dispatch is not blocked.',
                      style: TextStyle(
                        color: record.dispatchBlocked
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF15803D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (record.dispatchBlocked && !canOverride) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Override permission required (Admin/Compliance only).',
                      style: TextStyle(color: Color(0xFFB91C1C)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review Comments Panel',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _remarksController,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Reviewer Remarks'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _actionNoteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Mandatory Action Note (required if rejected)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _overrideReasonController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText:
                          'Override Reason (required if critical failures approved)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickNextInspectionDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _nextInspectionDate == null
                          ? 'Next Inspection Required Date'
                          : 'Next Inspection: ${_fmtDate(_nextInspectionDate!)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  final message = vm.approveInspection(
                    inspectionId: record.inspectionId,
                    reviewer: _reviewerName(role),
                    remarks: _remarksController.text.trim(),
                    nextInspectionDate: _nextInspectionDate,
                    role: role,
                    overrideReason: _overrideReasonController.text.trim(),
                  );
                  _handleResult(message);
                },
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: const Text('Approve'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  final message = vm.rejectInspection(
                    inspectionId: record.inspectionId,
                    reviewer: _reviewerName(role),
                    remarks: _remarksController.text.trim(),
                    mandatoryActionNote: _actionNoteController.text.trim(),
                    nextInspectionDate: _nextInspectionDate,
                  );
                  _handleResult(message);
                },
                icon: const Icon(Icons.thumb_down_alt_outlined),
                label: const Text('Reject'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  final message = vm.sendBackForCorrection(
                    inspectionId: record.inspectionId,
                    reviewer: _reviewerName(role),
                    remarks: _remarksController.text.trim(),
                  );
                  _handleResult(message);
                },
                icon: const Icon(Icons.reply_all_outlined),
                label: const Text('Send Back for Correction'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickNextInspectionDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDate:
          _nextInspectionDate ?? DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _nextInspectionDate = picked);
    }
  }

  String _reviewerName(UserRole? role) {
    if (role == null) {
      return 'Reviewer';
    }
    return role.label;
  }

  void _handleResult(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (message.toLowerCase().contains('approved') ||
        message.toLowerCase().contains('rejected') ||
        message.toLowerCase().contains('sent back')) {
      context.go(RoutePaths.inspectionDetailById(widget.inspectionId));
    }
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 180,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }
}
