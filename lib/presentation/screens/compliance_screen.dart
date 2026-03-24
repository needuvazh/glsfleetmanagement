import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/responsive.dart';
import '../viewmodels/compliance_viewmodel.dart';
import '../widgets/compliance_card.dart';
import '../widgets/kpi_card.dart';

class ComplianceScreen extends ConsumerWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complianceState = ref.watch(complianceViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compliance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: ref.read(complianceViewModelProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Search by vehicle id or status...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ComplianceFilter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final filter = ComplianceFilter.values[index];
                final selected = complianceState.valueOrNull?.filter == filter;

                return ChoiceChip(
                  label: Text(filter.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(complianceViewModelProvider.notifier)
                      .setFilter(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: complianceState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ComplianceError(
                message: error.toString(),
                onRetry: ref.read(complianceViewModelProvider.notifier).refresh,
              ),
              data: (state) {
                final items = state.filteredItems;
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh:
                        ref.read(complianceViewModelProvider.notifier).refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No compliance records found')),
                      ],
                    ),
                  );
                }

                final isMobile = Responsive.isMobile(context);

                return RefreshIndicator(
                  onRefresh: ref.read(complianceViewModelProvider.notifier).refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ComplianceSummary(state: state),
                      const SizedBox(height: 12),
                      Text(
                        'Updated ${_formatTime(state.lastUpdated)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      isMobile
                          ? Column(
                              children: [
                                for (int i = 0; i < items.length; i++) ...[
                                  ComplianceCard(record: items[i]),
                                  if (i != items.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              ],
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 2.1,
                              ),
                              itemBuilder: (_, index) =>
                                  ComplianceCard(record: items[index]),
                            ),
                    ],
                  ),
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

class _ComplianceSummary extends StatelessWidget {
  const _ComplianceSummary({required this.state});

  final ComplianceUiState state;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.isMobile(context) ? 1 : 3;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: Responsive.isMobile(context) ? 2.8 : 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        KpiCard(
          title: 'Compliant',
          value: '${state.compliantCount}',
          subtitle: 'All documents valid',
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF16A34A),
        ),
        KpiCard(
          title: 'Expiring Soon',
          value: '${state.expiringCount}',
          subtitle: 'Action needed within 30 days',
          icon: Icons.schedule_outlined,
          color: const Color(0xFFF59E0B),
        ),
        KpiCard(
          title: 'Overdue',
          value: '${state.overdueCount}',
          subtitle: 'Immediate compliance risk',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}

class _ComplianceError extends StatelessWidget {
  const _ComplianceError({required this.message, required this.onRetry});

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
