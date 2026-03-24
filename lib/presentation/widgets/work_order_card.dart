import 'package:flutter/material.dart';

import '../../domain/entities/work_order.dart';

class WorkOrderCard extends StatelessWidget {
  const WorkOrderCard({super.key, required this.workOrder});

  final WorkOrder workOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workOrder.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: workOrder.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Order: ${workOrder.id}'),
            const SizedBox(height: 4),
            Text('Vehicle: ${workOrder.vehicleId}'),
            const SizedBox(height: 4),
            Text(
              'Journey Plan: ${workOrder.journeyPlanId.isEmpty ? 'Not assigned' : workOrder.journeyPlanId}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PriorityChip(priority: workOrder.priority),
                const SizedBox(width: 8),
                Text(
                  'Due ${_formatDate(workOrder.dueDate)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Estimate: ${workOrder.estimatedDistance.toStringAsFixed(1)} km • ${workOrder.estimatedTime.toStringAsFixed(1)} hrs',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Created ${_formatDateTime(workOrder.createdAt)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _formatDateTime(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final WorkOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      WorkOrderStatus.open =>
        (const Color(0xFFF1F5F9), const Color(0xFF334155)),
      WorkOrderStatus.inProgress =>
        (const Color(0xFFFFF4DB), const Color(0xFF9A5B00)),
      WorkOrderStatus.completed =>
        (const Color(0xFFDFF6E8), const Color(0xFF1F7A47)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final WorkOrderPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      WorkOrderPriority.high =>
        (const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
      WorkOrderPriority.medium =>
        (const Color(0xFFFFF4DB), const Color(0xFF9A5B00)),
      WorkOrderPriority.low =>
        (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
