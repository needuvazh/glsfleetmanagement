import 'package:flutter/material.dart';

import '../../domain/entities/compliance_record.dart';

class ComplianceCard extends StatelessWidget {
  const ComplianceCard({super.key, required this.record});

  final ComplianceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg) = switch (record.complianceStatus) {
      ComplianceStatus.compliant =>
        (const Color(0xFFDFF6E8), const Color(0xFF1F7A47)),
      ComplianceStatus.expiringSoon =>
        (const Color(0xFFFFF4DB), const Color(0xFF9A5B00)),
      ComplianceStatus.overdue =>
        (const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
    };

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
                    record.vehicleId,
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
                    record.complianceStatus.label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DateRow(label: 'Registration', date: record.registrationExpiry),
            const SizedBox(height: 6),
            _DateRow(label: 'Insurance', date: record.insuranceExpiry),
            const SizedBox(height: 6),
            _DateRow(label: 'Inspection', date: record.inspectionDue),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 92, child: Text(label)),
        Text(_formatDate(date), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
