import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class JourneyManagementScreen extends ConsumerStatefulWidget {
  const JourneyManagementScreen({super.key});

  @override
  ConsumerState<JourneyManagementScreen> createState() =>
      _JourneyManagementScreenState();
}

class _JourneyManagementScreenState extends ConsumerState<JourneyManagementScreen> {
  bool _nightDriving = false;
  final _nightReason = TextEditingController();

  @override
  void dispose() {
    _nightReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Journey Management (JMP)',
      currentRoute: RoutePaths.journeyManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.tripExecution),
          child: const Text('Next'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final selected = data.selectedJourney;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 6),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Journey Plan Builder',
                subtitle: 'Auto-filled stops and ETA with approval controls',
                icon: Icons.alt_route_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selected?.journeyId,
                        decoration: const InputDecoration(labelText: 'Journey ID / Route'),
                        items: [
                          for (final j in data.journeyMaster)
                            DropdownMenuItem(
                              value: j.journeyId,
                              child: Text('${j.journeyId} • ${j.origin} -> ${j.destination}'),
                            ),
                        ],
                        onChanged: (value) =>
                            ref.read(logisticsViewModelProvider.notifier).setJourney(value),
                      ),
                      const SizedBox(height: 10),
                      Text('Vehicle: ${data.vehicles.isEmpty ? '-' : data.vehicles.first.vehicleNo}'),
                      Text('Driver: ${data.drivers.isEmpty ? '-' : data.drivers.first.name}'),
                      Text('Start Time: ${DateTime.now()}'),
                      const SizedBox(height: 8),
                      Text('Stops (Auto-filled): ${selected?.stops.join(' -> ') ?? '-'}'),
                      const SizedBox(height: 6),
                      Text('ETA per stop:'),
                      const SizedBox(height: 4),
                      if (selected != null)
                        for (int i = 0; i < selected.stops.length; i++)
                          Text('  - ${selected.stops[i]}: +${(i + 1) * 1.5} hrs'),
                      const SizedBox(height: 6),
                      Text('Rest Points: ${selected?.restPoints.join(', ') ?? '-'}'),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _nightDriving,
                        onChanged: (value) {
                          setState(() => _nightDriving = value);
                          ref
                              .read(logisticsViewModelProvider.notifier)
                              .setNightDriving(value, reason: _nightReason.text.trim());
                        },
                        title: const Text('Night Driving'),
                      ),
                      if (_nightDriving)
                        TextField(
                          controller: _nightReason,
                          onChanged: (value) => ref
                              .read(logisticsViewModelProvider.notifier)
                              .setNightDriving(true, reason: value),
                          decoration: const InputDecoration(
                            labelText: 'Reason (required for night driving)',
                          ),
                        ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: data.journeyApproved,
                        onChanged: (value) => ref
                            .read(logisticsViewModelProvider.notifier)
                            .approveJourney(value ?? false),
                        title: const Text('Journey Approval (Required)'),
                      ),
                      if (!data.journeyApproved)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Trip will be blocked until JMP is approved.',
                            style: TextStyle(color: Color(0xFFDC2626)),
                          ),
                        ),
                    ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
