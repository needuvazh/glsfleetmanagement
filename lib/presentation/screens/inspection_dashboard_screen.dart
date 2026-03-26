import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/inspection.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/inspection_viewmodel.dart';
import '../widgets/ops_shell.dart';

class InspectionDashboardScreen extends ConsumerWidget {
  const InspectionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionViewModelProvider);
    final vm = ref.read(inspectionViewModelProvider.notifier);

    final total = state.items.length;
    final pending = state.items.where((i) => i.approvalStatus == InspectionApprovalStatus.pending).length;
    final approved = state.items.where((i) => i.approvalStatus == InspectionApprovalStatus.approved).length;
    final rejected = state.items.where((i) => i.approvalStatus == InspectionApprovalStatus.rejected).length;

    return OpsShell(
      title: 'Inspection Dashboard',
      currentRoute: RoutePaths.inspectionDashboard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inspection Overview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _SummaryCard(
                  title: 'Total Inspections',
                  count: total,
                  color: Colors.blueGrey,
                  icon: Icons.assignment_outlined,
                  onTap: () {
                    vm.setQuery('');
                    vm.setStatusFilter('All');
                    vm.setPendingApprovalOnly(false);
                    context.push(RoutePaths.inspections);
                  },
                ),
                _SummaryCard(
                  title: 'Pending Approval',
                  count: pending,
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                  onTap: () {
                    vm.setQuery('');
                    vm.setStatusFilter('All');
                    vm.setPendingApprovalOnly(true);
                    context.push(RoutePaths.inspections);
                  },
                ),
                _SummaryCard(
                  title: 'Approved',
                  count: approved,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  onTap: () {
                    vm.setQuery('');
                    vm.setPendingApprovalOnly(false);
                    vm.setStatusFilter('Approved');
                    context.push(RoutePaths.inspections);
                  },
                ),
                _SummaryCard(
                  title: 'Rejected',
                  count: rejected,
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
                  onTap: () {
                    vm.setQuery('');
                    vm.setPendingApprovalOnly(false);
                    vm.setStatusFilter('Rejected');
                    context.push(RoutePaths.inspections);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
