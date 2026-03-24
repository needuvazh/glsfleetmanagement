import 'package:flutter/material.dart';

import '../../domain/entities/tracking_point.dart';

class TrackingVehicleCard extends StatelessWidget {
  const TrackingVehicleCard({
    super.key,
    required this.point,
    required this.isSelected,
    required this.onTap,
  });

  final TrackingPoint point;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      point.vehicleNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(point.status.label),
                ],
              ),
              const SizedBox(height: 6),
              Text('Driver: ${point.driver}'),
              const SizedBox(height: 4),
              Text('Speed: ${point.speedKph.toStringAsFixed(1)} km/h'),
              const SizedBox(height: 4),
              Text(
                'Lat ${point.latitude.toStringAsFixed(4)}, Lng ${point.longitude.toStringAsFixed(4)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
