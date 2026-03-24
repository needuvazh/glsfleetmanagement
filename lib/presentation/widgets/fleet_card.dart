import 'package:flutter/material.dart';

import '../../domain/entities/fleet.dart';
import 'fleet_status_chip.dart';

class FleetCard extends StatelessWidget {
  const FleetCard({super.key, required this.fleet});

  final Fleet fleet;

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
                    fleet.vehicleNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FleetStatusChip(status: fleet.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('${fleet.type} - Driver: ${fleet.driver}'),
            const SizedBox(height: 12),
            Text('Fuel: ${fleet.fuelLevel}%'),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: fleet.fuelLevel / 100,
              borderRadius: BorderRadius.circular(999),
              minHeight: 7,
            ),
            const SizedBox(height: 12),
            Text('Odometer: ${fleet.odometerKm} km'),
            const SizedBox(height: 4),
            Text(
              'Last service: ${fleet.lastServiceDate.year}-${fleet.lastServiceDate.month.toString().padLeft(2, '0')}-${fleet.lastServiceDate.day.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }
}
