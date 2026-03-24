import 'package:flutter/material.dart';

import '../../domain/entities/fleet.dart';

class FleetStatusChip extends StatelessWidget {
  const FleetStatusChip({super.key, required this.status});

  final FleetStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      FleetStatus.active =>
        (const Color(0xFFDFF6E8), const Color(0xFF1F7A47)),
      FleetStatus.maintenance =>
        (const Color(0xFFFDECCC), const Color(0xFF9A5B00)),
      FleetStatus.idle =>
        (const Color(0xFFE6EDF8), const Color(0xFF35516E)),
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
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
