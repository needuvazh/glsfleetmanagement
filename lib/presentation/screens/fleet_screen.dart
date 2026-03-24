import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/responsive.dart';
import '../viewmodels/fleet_viewmodel.dart';
import '../widgets/fleet_card.dart';

class FleetScreen extends ConsumerWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fleetState = ref.watch(fleetViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fleet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged:
                  ref.read(fleetViewModelProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Search by vehicle, driver, type, status...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: FleetFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = FleetFilter.values[index];
                final selected =
                    fleetState.valueOrNull?.filter == filter;

                return ChoiceChip(
                  label: Text(filter.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(fleetViewModelProvider.notifier)
                      .setFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: fleetState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _FleetError(
                message: error.toString(),
                onRetry: ref.read(fleetViewModelProvider.notifier).refresh,
              ),
              data: (state) {
                final items = state.filteredItems;

                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh:
                        ref.read(fleetViewModelProvider.notifier).refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 160),
                        Center(child: Text('No vehicles found')),
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
                          Text('Showing ${items.length} vehicles'),
                          const Spacer(),
                          Text(
                            'Updated ${_time(state.lastUpdated)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh:
                            ref.read(fleetViewModelProvider.notifier).refresh,
                        child: isMobile
                            ? ListView.separated(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) =>
                                    FleetCard(fleet: items[index]),
                              )
                            : GridView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
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
                                    FleetCard(fleet: items[index]),
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

  String _time(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class _FleetError extends StatelessWidget {
  const _FleetError({required this.message, required this.onRetry});

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
            const Icon(Icons.error_outline, size: 32),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
