import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/responsive.dart';
import '../../domain/entities/journey_plan.dart';
import '../viewmodels/journey_plan_viewmodel.dart';

class JourneyPlanScreen extends ConsumerWidget {
  const JourneyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyState = ref.watch(journeyPlanViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journey Plans')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: ref.read(journeyPlanViewModelProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Search plan, origin, destination, stops...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: journeyState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _JourneyError(
                message: error.toString(),
                onRetry: ref.read(journeyPlanViewModelProvider.notifier).refresh,
              ),
              data: (state) {
                final items = state.filteredItems;
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh:
                        ref.read(journeyPlanViewModelProvider.notifier).refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No journey plans found')),
                      ],
                    ),
                  );
                }

                final isMobile = Responsive.isMobile(context);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('Plans ${items.length}'),
                          const Spacer(),
                          Text(
                            'Updated ${_formatTime(state.lastUpdated)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh:
                            ref.read(journeyPlanViewModelProvider.notifier).refresh,
                        child: isMobile
                            ? ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) =>
                                    _JourneyCard(plan: items[index]),
                              )
                            : GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.8,
                                ),
                                itemBuilder: (_, index) =>
                                    _JourneyCard(plan: items[index]),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.plan});

  final JourneyPlan plan;

  @override
  Widget build(BuildContext context) {
    final stopsText = plan.stops.isEmpty ? 'Direct route' : plan.stops.join(' -> ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.planName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Route: ${plan.origin} -> ${plan.destination}'),
            const SizedBox(height: 6),
            Text('Distance: ${plan.distance.toStringAsFixed(1)} km'),
            const SizedBox(height: 6),
            Text('Estimated Time: ${plan.estimatedTime.toStringAsFixed(1)} hrs'),
            const SizedBox(height: 6),
            Text('Stops: $stopsText'),
            const SizedBox(height: 6),
            Text('Fuel Estimate: ${plan.fuelEstimate.toStringAsFixed(1)} L'),
          ],
        ),
      ),
    );
  }
}

class _JourneyError extends StatelessWidget {
  const _JourneyError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 34),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
