import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/responsive.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/work_order_draft_viewmodel.dart';
import '../viewmodels/work_orders_viewmodel.dart';
import '../widgets/work_order_card.dart';

class WorkOrdersScreen extends ConsumerWidget {
  const WorkOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workOrdersState = ref.watch(workOrdersViewModelProvider);
    final draft = ref.watch(workOrderDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Orders'),
        actions: [
          IconButton(
            tooltip: 'Create Work Order',
            onPressed: () => context.push(RoutePaths.createWorkOrder),
            icon: const Icon(Icons.add_task),
          ),
        ],
      ),
      body: Column(
        children: [
          if (draft.hasContent)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.drafts_outlined),
                  title: const Text('Draft available'),
                  subtitle: const Text('Resume your saved work order draft'),
                  trailing: Wrap(
                    spacing: 6,
                    children: [
                      TextButton(
                        onPressed: () =>
                            ref.read(workOrderDraftProvider.notifier).clearDraft(),
                        child: const Text('Discard'),
                      ),
                      TextButton(
                        onPressed: () => context.push(RoutePaths.createWorkOrder),
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: ref.read(workOrdersViewModelProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Search by order id, title, vehicle...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: WorkOrderStatusFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = WorkOrderStatusFilter.values[index];
                final selected = workOrdersState.valueOrNull?.statusFilter == filter;

                return ChoiceChip(
                  label: Text(filter.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(workOrdersViewModelProvider.notifier)
                      .setStatusFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: WorkOrderPriorityFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = WorkOrderPriorityFilter.values[index];
                final selected =
                    workOrdersState.valueOrNull?.priorityFilter == filter;

                return ChoiceChip(
                  label: Text('${filter.label} Priority'),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(workOrdersViewModelProvider.notifier)
                      .setPriorityFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: workOrdersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _WorkOrdersError(
                message: error.toString(),
                onRetry: ref.read(workOrdersViewModelProvider.notifier).refresh,
              ),
              data: (state) {
                final items = state.filteredItems;

                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: ref.read(workOrdersViewModelProvider.notifier).refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No work orders found')),
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
                          Text('Showing ${items.length} work orders'),
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
                            ref.read(workOrdersViewModelProvider.notifier).refresh,
                        child: isMobile
                            ? ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) =>
                                    WorkOrderCard(workOrder: items[index]),
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
                                    WorkOrderCard(workOrder: items[index]),
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

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class _WorkOrdersError extends StatelessWidget {
  const _WorkOrdersError({required this.message, required this.onRetry});

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
