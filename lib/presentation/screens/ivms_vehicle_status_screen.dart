import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transport_fleet_management/core/theme/app_theme.dart';
import 'package:transport_fleet_management/domain/entities/ivms_data.dart';
import 'package:transport_fleet_management/presentation/viewmodels/ivms_viewmodel.dart';

class IVMSVehicleStatusScreen extends ConsumerStatefulWidget {
  const IVMSVehicleStatusScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IVMSVehicleStatusScreen> createState() => _IVMSVehicleStatusScreenState();
}

class _IVMSVehicleStatusScreenState extends ConsumerState<IVMSVehicleStatusScreen> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final ivmsState = ref.watch(ivmsViewModelProvider);
    final ivmsViewModel = ref.read(ivmsViewModelProvider.notifier);

    var filteredVehicles = ivmsState.vehicleTracking;
    if (_selectedStatus != 'All') {
      filteredVehicles = filteredVehicles.where((v) => v.status == _selectedStatus).toList();
    }

    final movingCount = ivmsViewModel.getMovingVehiclesCount();
    final idleCount = ivmsViewModel.getIdleVehiclesCount();
    final offlineCount = ivmsViewModel.getOfflineVehiclesCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('IVMS Vehicle Status'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Fleet Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SummaryCard(
                    title: 'Moving',
                    count: movingCount,
                    icon: Icons.directions_car,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    title: 'Idle',
                    count: idleCount,
                    icon: Icons.pause_circle,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    title: 'Offline',
                    count: offlineCount,
                    icon: Icons.error,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    title: 'Total',
                    count: ivmsState.vehicleTracking.length,
                    icon: Icons.local_shipping,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          // Status Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'MOVING', 'IDLE', 'STOPPED', 'OFFLINE'].map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = status);
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Vehicle List
          Expanded(
            child: filteredVehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];
                      return _VehicleStatusCard(
                        vehicle: vehicle,
                        onTap: () => _showVehicleDetails(context, vehicle),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetails(BuildContext context, IVMSData vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VehicleDetailsSheet(vehicle: vehicle),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _VehicleStatusCard extends StatelessWidget {
  final IVMSData vehicle;
  final VoidCallback onTap;

  const _VehicleStatusCard({
    required this.vehicle,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (vehicle.status) {
      case 'MOVING':
        return Colors.green;
      case 'IDLE':
        return Colors.orange;
      case 'STOPPED':
        return Colors.orange;
      case 'OFFLINE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleRegistration,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          vehicle.driverName ?? 'No Driver',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vehicle.status,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Location Info
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vehicle.lastLocation ?? 'Unknown Location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status Indicators Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatusIndicator(
                    icon: Icons.speed,
                    label: 'Speed',
                    value: '${vehicle.speed.toStringAsFixed(1)} km/h',
                  ),
                  _StatusIndicator(
                    icon: Icons.local_gas_station,
                    label: 'Fuel',
                    value: '${vehicle.fuelLevel.toStringAsFixed(1)}%',
                  ),
                  _StatusIndicator(
                    icon: Icons.thermostat,
                    label: 'Temp',
                    value: '${vehicle.temperature.toStringAsFixed(0)}°C',
                  ),
                  _StatusIndicator(
                    icon: Icons.timeline,
                    label: 'ODO',
                    value: '${(vehicle.odometer / 1000).toStringAsFixed(1)}K km',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Additional Info
              if (vehicle.tripDuration != null && vehicle.tripDuration! > 0)
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Trip: ${vehicle.tripDuration} min | Distance: ${vehicle.distanceTraveled?.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Last Update: ${_formatTime(vehicle.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusIndicator({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class _VehicleDetailsSheet extends StatelessWidget {
  final IVMSData vehicle;

  const _VehicleDetailsSheet({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vehicle: ${vehicle.vehicleRegistration}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _DetailRow('Status', vehicle.status),
            _DetailRow('Driver', vehicle.driverName ?? 'Unknown'),
            _DetailRow('Location', vehicle.lastLocation ?? 'Unknown'),
            _DetailRow('Speed', '${vehicle.speed.toStringAsFixed(1)} km/h'),
            _DetailRow('Fuel Level', '${vehicle.fuelLevel.toStringAsFixed(1)}%'),
            _DetailRow('Temperature', '${vehicle.temperature.toStringAsFixed(1)}°C'),
            _DetailRow('RPM', vehicle.rpm.toString()),
            _DetailRow('Odometer', '${vehicle.odometer.toStringAsFixed(1)} km'),
            _DetailRow('Engine', vehicle.engineStatus ? 'Running' : 'Off'),
            _DetailRow('Doors', vehicle.doorsLocked ? 'Locked' : 'Unlocked'),
            if (vehicle.tripDuration != null && vehicle.tripDuration! > 0) ...[
              _DetailRow('Trip Duration', '${vehicle.tripDuration} minutes'),
              _DetailRow('Distance Traveled', '${vehicle.distanceTraveled?.toStringAsFixed(1)} km'),
            ],
            _DetailRow('Coordinates', '${vehicle.latitude.toStringAsFixed(4)}, ${vehicle.longitude.toStringAsFixed(4)}'),
            _DetailRow('Last Update', vehicle.timestamp.toString()),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
