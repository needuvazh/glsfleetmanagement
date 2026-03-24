import 'package:flutter/material.dart';

import '../../domain/entities/alert_item.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.onToggleRead,
  });

  final AlertItem alert;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg) = switch (alert.severity) {
      AlertSeverity.high =>
        (const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
      AlertSeverity.medium =>
        (const Color(0xFFFFF4DB), const Color(0xFF9A5B00)),
      AlertSeverity.low =>
        (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onToggleRead,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      alert.type,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      alert.severity.label,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(alert.message),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    alert.isRead
                        ? Icons.mark_email_read_outlined
                        : Icons.mark_email_unread_outlined,
                    size: 16,
                    color: alert.isRead
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(alert.isRead ? 'Read' : 'Unread'),
                  const Spacer(),
                  Text('Vehicle ${alert.vehicleId}'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatTimestamp(alert.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
