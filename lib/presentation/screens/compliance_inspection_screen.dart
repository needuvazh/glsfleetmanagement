import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class ComplianceInspectionScreen extends ConsumerWidget {
  const ComplianceInspectionScreen({super.key});

  static const labels = {
    'vehicleDocsValid': 'Vehicle Documents Valid',
    'driverDocsValid': 'Driver Documents Valid',
    'tyres': 'Tyres',
    'brake': 'Brake',
    'lights': 'Lights',
    'fireExtinguisher': 'Fire Extinguisher',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Compliance & Inspection',
      currentRoute: RoutePaths.complianceInspection,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.journeyManagement),
          child: const Text('Next'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 7),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Document Status',
                subtitle: 'Vehicle and driver compliance state',
                icon: Icons.rule_folder_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehicle Documents: ${data.vehicleDocStatus}'),
                    Text('Driver Documents: ${data.driverDocStatus}'),
                    if (data.vehicleDocStatus == 'Expired' ||
                        data.driverDocStatus == 'Expired')
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Block: expired documents detected.',
                          style: TextStyle(color: Color(0xFFDC2626)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Pre-Trip Inspection',
                subtitle: 'Checklist: tyres, brake, lights, fire extinguisher',
                icon: Icons.verified_user_outlined,
                accent: const Color(0xFF16A34A),
                child: Column(
                    children: [
                      for (final entry in data.complianceChecklist.entries)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: entry.value,
                          title: Text(labels[entry.key] ?? entry.key),
                          onChanged: (value) => ref
                              .read(logisticsViewModelProvider.notifier)
                              .updateChecklist(entry.key, value),
                        ),
                    ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    final message =
                        ref.read(logisticsViewModelProvider.notifier).finalizePreTrip();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  child: const Text('Finalize Pre-Trip'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: data.compliancePassed
                    ? const Color(0xFFEAF7EF)
                    : const Color(0xFFFFEFEF),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        data.compliancePassed
                            ? Icons.verified_outlined
                            : Icons.block_outlined,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.compliancePassed
                              ? 'Compliance complete. Trip can proceed.'
                              : 'Critical compliance failed. Trip is blocked.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
