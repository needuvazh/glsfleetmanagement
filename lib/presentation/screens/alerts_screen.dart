import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/responsive.dart';
import '../viewmodels/alerts_viewmodel.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(alertsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton(
            onPressed: () => ref.read(alertsViewModelProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: ref.read(alertsViewModelProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Search by alert id, type, vehicle, message...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: AlertsSeverityFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = AlertsSeverityFilter.values[index];
                final selected =
                    alertsState.valueOrNull?.severityFilter == filter;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(alertsViewModelProvider.notifier)
                      .setSeverityFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: AlertsReadFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = AlertsReadFilter.values[index];
                final selected = alertsState.valueOrNull?.readFilter == filter;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(alertsViewModelProvider.notifier)
                      .setReadFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: alertsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _AlertsError(
                message: error.toString(),
                onRetry: ref.read(alertsViewModelProvider.notifier).refresh,
              ),
              data: (state) {
                final items = state.filteredItems;
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: ref.read(alertsViewModelProvider.notifier).refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No alerts found')),
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
                          Text('Unread ${state.unreadCount}'),
                          const SizedBox(width: 10),
                          Text('High ${state.highCount}'),
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
                            ref.read(alertsViewModelProvider.notifier).refresh,
                        child: isMobile
                            ? ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) => AlertCard(
                                  alert: items[index],
                                  onToggleRead: () => ref
                                      .read(alertsViewModelProvider.notifier)
                                      .toggleRead(items[index].id),
                                ),
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
                                  childAspectRatio: 2.0,
                                ),
                                itemBuilder: (_, index) => AlertCard(
                                  alert: items[index],
                                  onToggleRead: () => ref
                                      .read(alertsViewModelProvider.notifier)
                                      .toggleRead(items[index].id),
                                ),
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

class _AlertsError extends StatelessWidget {
  const _AlertsError({required this.message, required this.onRetry});

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
