import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class TripExecutionScreen extends ConsumerWidget {
  const TripExecutionScreen({super.key});

  static const timeline = [
    'Trip Started',
    'Loading',
    'In Transit',
    'Stop Points',
    'Delay Alerts',
    'Near Destination',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'Trip Execution & Tracking (IVMS / DFMS)',
      currentRoute: RoutePaths.tripExecution,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.deliveryPod),
          child: const Text('Next'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          final ivms = data.ivms.isEmpty ? null : data.ivms.first;
          final dfms = data.dfms.isEmpty ? null : data.dfms.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 8),
              const SizedBox(height: 12),
              if (!data.canStartTrip)
                Card(
                  color: const Color(0xFFFFEFEF),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Trip blocked until assignment, compliance, JMP approval, and pre-trip pass are complete.',
                    ),
                  ),
                ),
              if (!data.canStartTrip) const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      final msg = ref.read(logisticsViewModelProvider.notifier).startTrip();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Trip'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(logisticsViewModelProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Live Data'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'IVMS Tracking (Mock)',
                subtitle: 'Live coordinates, speed and fuel simulation',
                icon: Icons.sensors_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IVMS Tracking (Mock)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (ivms != null) ...[
                        Text('Vehicle: ${ivms.vehicleId}'),
                        Text('Lat: ${ivms.lat.toStringAsFixed(4)}  Lng: ${ivms.lng.toStringAsFixed(4)}'),
                        Text('Speed: ${ivms.speed.toStringAsFixed(0)} km/h'),
                        Text('Distance Covered: ${ivms.distanceCovered.toStringAsFixed(1)} km'),
                        Text('Fuel Level: ${ivms.fuelLevel.toStringAsFixed(0)}%'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: min(1, ivms.distanceCovered / 350),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ] else
                        const Text('No IVMS data available'),
                      const SizedBox(height: 10),
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF2F6FD),
                          border: Border.all(color: const Color(0xFFD9E3F4)),
                        ),
                        child: const Center(child: Text('Map View Placeholder (Mock Coordinates)')),
                      ),
                    ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'DFMS Driver Monitoring (Mock)',
                subtitle: 'Fatigue, eye closure and driving hour checks',
                icon: Icons.psychology_outlined,
                accent: const Color(0xFF14B8A6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DFMS Driver Monitoring (Mock)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (dfms != null) ...[
                        Text('Driver: ${dfms.driverId}'),
                        Text('Fatigue Level: ${dfms.fatigueLevel}'),
                        Text('Eye Closure Rate: ${dfms.eyeClosureRate.toStringAsFixed(2)}'),
                        Text('Driving Hours: ${dfms.drivingHours.toStringAsFixed(1)}'),
                        Text('Alert: ${dfms.alert}'),
                        if (dfms.fatigueLevel.toLowerCase() == 'high')
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEFEF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('High fatigue detected. Suggest nearest rest stop.'),
                          ),
                      ] else
                        const Text('No DFMS data available'),
                    ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Alert System',
                subtitle: 'Overspeed, fatigue, route deviation and low fuel',
                icon: Icons.notification_important_outlined,
                accent: const Color(0xFFDC2626),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alert System',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      for (final alert in data.executionAlerts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('- $alert'),
                        ),
                    ],
                ),
              ),
              const SizedBox(height: 12),
              OpsSectionCard(
                title: 'Trip Timeline',
                subtitle: 'Stepper progression from start to delivery',
                icon: Icons.timeline_outlined,
                accent: const Color(0xFF7C3AED),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip Timeline',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      for (int i = 0; i < timeline.length; i++)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            i <= data.timelineStep
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: i <= data.timelineStep
                                ? const Color(0xFF16A34A)
                                : null,
                          ),
                          title: Text(timeline[i]),
                          trailing: i < timeline.length - 1
                              ? TextButton(
                                  onPressed: () => ref
                                      .read(logisticsViewModelProvider.notifier)
                                      .updateTimelineStep(i + 1),
                                  child: const Text('Mark'),
                                )
                              : null,
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
