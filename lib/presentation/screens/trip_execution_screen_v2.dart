import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/flow_stepper_card.dart';
import '../widgets/ops_shell.dart';
import '../widgets/media_capture_widget.dart';

class TripExecutionScreenV2 extends ConsumerStatefulWidget {
  const TripExecutionScreenV2({super.key});

  @override
  ConsumerState<TripExecutionScreenV2> createState() => _TripExecutionScreenV2State();
}

class _TripExecutionScreenV2State extends ConsumerState<TripExecutionScreenV2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> _preChecklistItems = {};
  List<String> _pickupMediaList = [];
  List<String> _dropMediaList = [];
  bool _tripStarted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleStartTrip() {
    if (_preChecklistItems.values.where((v) => v).length != _preChecklistItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all pre-trip checks before starting')),
      );
      return;
    }

    final message = ref.read(logisticsViewModelProvider.notifier).startTrip();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (message.contains('successfully')) {
      setState(() => _tripStarted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logisticsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OpsShell(
      title: 'Trip Execution',
      currentRoute: RoutePaths.tripExecution,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const FlowStepperCard(currentStep: 8),
              const SizedBox(height: 16),
              // Trip Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trip ID: ${data.assignedOrderId ?? 'N/A'}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vehicle: ${data.assignedVehicleNo ?? 'N/A'}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _tripStarted ? colorScheme.tertiaryContainer : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _tripStarted ? 'In Progress' : 'Ready',
                              style: textTheme.labelSmall?.copyWith(
                                color: _tripStarted ? colorScheme.onTertiaryContainer : colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tabbed Interface
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Pre-Trip'),
                    Tab(text: 'Pickup'),
                    Tab(text: 'Drop'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Content
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pre-Trip Tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          PreTripChecklistWidget(
                            initialChecklist: _preChecklistItems,
                            onChecklistComplete: (checklist) {
                              setState(() => _preChecklistItems = checklist);
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _tripStarted ? null : _handleStartTrip,
                              child: Text(_tripStarted ? 'Trip Started' : 'Start Trip'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Pickup Tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          MediaCaptureWidget(
                            title: 'Pickup Evidence',
                            mediaList: _pickupMediaList,
                            onMediaAdded: (path) {
                              setState(() => _pickupMediaList.add(path));
                            },
                            onMediaRemoved: (path) {
                              setState(() => _pickupMediaList.remove(path));
                            },
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Details',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Pickup Notes',
                                      hintText: 'Add any notes about the pickup...',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Pickup confirmed')),
                                        );
                                      },
                                      child: const Text('Confirm Pickup'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Drop Tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          MediaCaptureWidget(
                            title: 'Drop Evidence',
                            mediaList: _dropMediaList,
                            onMediaAdded: (path) {
                              setState(() => _dropMediaList.add(path));
                            },
                            onMediaRemoved: (path) {
                              setState(() => _dropMediaList.remove(path));
                            },
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivery Details',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Delivery Notes',
                                      hintText: 'Add any notes about the delivery...',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _dropMediaList.isEmpty
                                          ? null
                                          : () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Delivery confirmed')),
                                              );
                                            },
                                      child: const Text('Confirm Delivery'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
