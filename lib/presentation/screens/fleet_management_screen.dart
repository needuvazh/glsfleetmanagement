import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FleetManagementScreen extends ConsumerWidget {
  const FleetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Fleet Management',
      currentRoute: RoutePaths.fleetManagement,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.driverManagement),
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
                title: 'Fleet Registry',
                subtitle: 'Vehicle, capacity, IVMS device and status',
                icon: Icons.local_shipping_outlined,
                accent: const Color(0xFF2563EB),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFEFF4FF)),
                    columns: const [
                      DataColumn(label: Text('Vehicle No')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Capacity')),
                      DataColumn(label: Text('Fuel Type')),
                      DataColumn(label: Text('IVMS Device ID')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: [
                      for (final item in data.vehicles)
                        DataRow(
                          cells: [
                            DataCell(Text(item.vehicleNo)),
                            DataCell(Text(item.type)),
                            DataCell(Text(item.capacity)),
                            DataCell(Text(item.fuelType)),
                            DataCell(Text(item.ivmsDeviceId)),
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
