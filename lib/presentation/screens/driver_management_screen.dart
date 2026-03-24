import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class DriverManagementScreen extends ConsumerWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Driver Management',
      currentRoute: RoutePaths.driverManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.complianceInspection),
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
              const FlowStepperCard(currentStep: 3),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Driver Registry',
                subtitle: 'License, DFMS device and availability',
                icon: Icons.badge_outlined,
                accent: const Color(0xFF14B8A6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('License No')),
                      DataColumn(label: Text('Expiry Date')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Experience')),
                      DataColumn(label: Text('DFMS Device ID')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: [
                      for (final item in data.drivers)
                        DataRow(
                          cells: [
                            DataCell(Text(item.name)),
                            DataCell(Text(item.licenseNo)),
                            DataCell(Text(item.expiryDate)),
                            DataCell(Text(item.phone)),
                            DataCell(Text('${item.experience} yrs')),
                            DataCell(Text(item.dfmsDeviceId)),
                            DataCell(Text(item.status)),
                          ],
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
