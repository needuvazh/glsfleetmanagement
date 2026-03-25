import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionCreateScreen extends ConsumerStatefulWidget {
  const InspectionCreateScreen({super.key});

  @override
  ConsumerState<InspectionCreateScreen> createState() =>
      _InspectionCreateScreenState();
}

class _InspectionCreateScreenState
    extends ConsumerState<InspectionCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _inspectionIdController = TextEditingController();
  final _workOrderController = TextEditingController();
  final _fleetController = TextEditingController();
  final _trailerController = TextEditingController();
  final _driverController = TextEditingController();
  final _inspectorController = TextEditingController();
  final _notesController = TextEditingController();
  final _correctiveActionController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _reviewerController = TextEditingController();

  InspectionType _type = InspectionType.preTrip;
  DateTime _inspectionDateTime = DateTime.now();

  late final List<_ChecklistDraft> _items;

  @override
  void initState() {
    super.initState();
    _inspectionIdController.text =
        'INS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    _items = [
      _ChecklistDraft(itemName: 'Tyres'),
      _ChecklistDraft(itemName: 'Brake'),
      _ChecklistDraft(itemName: 'Lights'),
      _ChecklistDraft(itemName: 'Fire Extinguisher'),
      _ChecklistDraft(itemName: 'Vehicle Documents'),
      _ChecklistDraft(itemName: 'Driver Documents'),
    ];
  }

  @override
  void dispose() {
    _inspectionIdController.dispose();
    _workOrderController.dispose();
    _fleetController.dispose();
    _trailerController.dispose();
    _driverController.dispose();
    _inspectorController.dispose();
    _notesController.dispose();
    _correctiveActionController.dispose();
    _recommendationController.dispose();
    _reviewerController.dispose();
    for (final item in _items) {
      item.remarksController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OpsShell(
      title: 'Create Inspection',
      currentRoute: RoutePaths.inspections,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _Section(
              title: 'A. Inspection Header',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _field(_inspectionIdController, 'Inspection ID',
                      required: true, width: 260),
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<InspectionType>(
                      value: _type,
                      decoration:
                          const InputDecoration(labelText: 'Inspection Type'),
                      items: [
                        for (final type in InspectionType.values)
                          DropdownMenuItem(
                              value: type, child: Text(type.label)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                  ),
                  _field(_workOrderController, 'Linked Work Order',
                      required: true),
                  _field(_fleetController, 'Linked Fleet', required: true),
                  _field(_trailerController, 'Linked Trailer'),
                  _field(_driverController, 'Linked Driver', required: true),
                  _field(_inspectorController, 'Inspector Name',
                      required: true),
                  SizedBox(
                    width: 260,
                    child: OutlinedButton.icon(
                      onPressed: _pickInspectionDateTime,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                          'Inspection At: ${_fmtDateTime(_inspectionDateTime)}'),
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'B. Checklist Items',
              child: Column(
                children: [
                  for (final item in _items)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(item.itemName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                                FilterChip(
                                  selected: item.passed,
                                  label: const Text('Pass'),
                                  onSelected: (_) =>
                                      setState(() => item.passed = true),
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  selected: !item.passed,
                                  label: const Text('Fail'),
                                  onSelected: (_) =>
                                      setState(() => item.passed = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: item.remarksController,
                                    decoration: const InputDecoration(
                                        labelText: 'Remarks'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 180,
                                  child: DropdownButtonFormField<
                                      InspectionFailureSeverity>(
                                    value: item.severity,
                                    decoration: const InputDecoration(
                                        labelText: 'Severity if Failed'),
                                    items: [
                                      for (final severity
                                          in InspectionFailureSeverity.values)
                                        DropdownMenuItem(
                                          value: severity,
                                          child: Text(severity.label),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => item.severity = value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => item.mediaCount += 1);
                                    _toast(
                                        'Media attach placeholder: +1 evidence added.');
                                  },
                                  icon: const Icon(Icons.attachment_outlined),
                                  label: Text('Media (${item.mediaCount})'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'C. General Comments',
              child: Column(
                children: [
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _correctiveActionController,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Corrective Action'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _recommendationController,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Recommendation'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'D. Evidence',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _toast('Upload image placeholder'),
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Upload Image'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _toast('Upload video placeholder'),
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Upload Video'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _toast('Attach document placeholder'),
                    icon: const Icon(Icons.attach_file_outlined),
                    label: const Text('Attach Document (Placeholder)'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'E. Sign-off',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _field(_inspectorController, 'Inspector Name',
                      required: true),
                  _field(_reviewerController, 'Reviewer Name'),
                  OutlinedButton.icon(
                    onPressed: () => _toast('Signature placeholder'),
                    icon: const Icon(Icons.draw_outlined),
                    label: const Text('Signature (Placeholder)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _submit(InspectionStatus.draft, InspectionResult.passed),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Draft'),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _submit(InspectionStatus.submitted, _computedResult()),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      _submit(InspectionStatus.passed, InspectionResult.passed),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Mark Passed'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      _submit(InspectionStatus.failed, InspectionResult.failed),
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('Mark Failed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    double width = 260,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  InspectionResult _computedResult() {
    final hasFailed = _items.any((item) => !item.passed);
    return hasFailed ? InspectionResult.failed : InspectionResult.passed;
  }

  Future<void> _pickInspectionDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _inspectionDateTime,
    );
    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_inspectionDateTime),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _inspectionDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit(InspectionStatus status, InspectionResult result) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final checklist = _items
        .map(
          (item) => InspectionChecklistItemResult(
            itemName: item.itemName,
            passed: item.passed,
            remarks: item.remarksController.text.trim(),
            mediaCount: item.mediaCount,
            severity:
                item.passed ? InspectionFailureSeverity.none : item.severity,
          ),
        )
        .toList();

    final approvalStatus = status == InspectionStatus.submitted
        ? InspectionApprovalStatus.pending
        : (status == InspectionStatus.approved
            ? InspectionApprovalStatus.approved
            : (status == InspectionStatus.rejected
                ? InspectionApprovalStatus.rejected
                : InspectionApprovalStatus.none));

    final record = InspectionRecord(
      inspectionId: _inspectionIdController.text.trim(),
      inspectionType: _type,
      workOrder: _workOrderController.text.trim(),
      fleet: _fleetController.text.trim(),
      trailer: _trailerController.text.trim(),
      driver: _driverController.text.trim(),
      inspector: _inspectorController.text.trim(),
      inspectedAt: _inspectionDateTime,
      overallResult: result,
      status: status,
      approvalStatus: approvalStatus,
      mediaCount: checklist.fold<int>(0, (sum, item) => sum + item.mediaCount),
      lastUpdated: DateTime.now(),
      checklistItems: checklist,
      notes: _notesController.text.trim(),
      correctiveAction: _correctiveActionController.text.trim(),
      recommendation: _recommendationController.text.trim(),
      reviewerName: _reviewerController.text.trim(),
      signaturePlaceholder: true,
    );

    ref.read(inspectionViewModelProvider.notifier).createInspection(record);
    _toast('Inspection ${record.inspectionId} saved as ${status.label}.');
    context.go(RoutePaths.inspections);
  }

  String _fmtDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $hour:$minute';
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

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
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChecklistDraft {
  _ChecklistDraft({required this.itemName})
      : remarksController = TextEditingController();

  final String itemName;
  final TextEditingController remarksController;
  bool passed = true;
  int mediaCount = 0;
  InspectionFailureSeverity severity = InspectionFailureSeverity.low;
}
