import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/journey_plan.dart';
import '../../domain/entities/work_order.dart';
import '../viewmodels/journey_plan_viewmodel.dart';
import '../viewmodels/work_order_draft_viewmodel.dart';
import '../viewmodels/work_orders_viewmodel.dart';

class CreateWorkOrderScreen extends ConsumerStatefulWidget {
  const CreateWorkOrderScreen({super.key});

  @override
  ConsumerState<CreateWorkOrderScreen> createState() =>
      _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends ConsumerState<CreateWorkOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _vehicleController = TextEditingController();

  WorkOrderPriority _priority = WorkOrderPriority.medium;
  String? _journeyPlanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(workOrderDraftProvider);
      setState(() {
        _titleController.text = draft.title;
        _vehicleController.text = draft.vehicleId;
        _priority = draft.priority;
        _journeyPlanId = draft.journeyPlanId;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journeyState = ref.watch(journeyPlanViewModelProvider);
    final plans = journeyState.valueOrNull?.items ?? const <JourneyPlan>[];

    final selectedPlan = plans.where((p) => p.id == _journeyPlanId).isEmpty
        ? (plans.isEmpty ? null : plans.first)
        : plans.firstWhere((p) => p.id == _journeyPlanId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Work Order'),
        actions: [
          TextButton(
            onPressed: () async => _saveDraft(),
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: journeyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load plans: $error')),
        data: (_) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Work Order Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  hintText: 'e.g. 8603 BK',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _journeyPlanId ?? (plans.isEmpty ? null : plans.first.id),
                decoration: const InputDecoration(
                  labelText: 'Journey Plan',
                  prefixIcon: Icon(Icons.alt_route_outlined),
                ),
                items: [
                  for (final plan in plans)
                    DropdownMenuItem(
                      value: plan.id,
                      child: Text('${plan.planName} (${plan.origin} -> ${plan.destination})'),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _journeyPlanId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select journey plan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WorkOrderPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: [
                  for (final p in WorkOrderPriority.values)
                    DropdownMenuItem(value: p, child: Text('${p.label} Priority')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _priority = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (selectedPlan != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Estimate: ${selectedPlan.distance.toStringAsFixed(1)} km • ${selectedPlan.estimatedTime.toStringAsFixed(1)} hrs\nStops: ${selectedPlan.stops.join(', ')}',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async => _createOrder(plans),
                icon: const Icon(Icons.add_task),
                label: const Text('Create Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    await ref.read(workOrderDraftProvider.notifier).saveDraft(
          WorkOrderDraft(
            title: _titleController.text.trim(),
            vehicleId: _vehicleController.text.trim(),
            journeyPlanId: _journeyPlanId,
            priority: _priority,
          ),
        );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved')),
    );
  }

  Future<void> _createOrder(List<JourneyPlan> plans) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_journeyPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a journey plan')),
      );
      return;
    }

    JourneyPlan? selectedPlan;
    for (final plan in plans) {
      if (plan.id == _journeyPlanId) {
        selectedPlan = plan;
        break;
      }
    }

    if (selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journey plan not found')),
      );
      return;
    }

    ref.read(workOrdersViewModelProvider.notifier).createOrderFromJourneyPlan(
          plan: selectedPlan,
          vehicleId: _vehicleController.text.trim(),
          title: _titleController.text.trim(),
          priority: _priority,
        );

    await ref.read(workOrderDraftProvider.notifier).clearDraft();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created order from ${selectedPlan.planName}')),
      );
      context.pop();
    }
  }
}
