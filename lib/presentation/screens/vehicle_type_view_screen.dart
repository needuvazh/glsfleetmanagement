import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/vehicle_type_master_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VehicleTypeViewScreen extends ConsumerWidget {
  const VehicleTypeViewScreen({
    super.key,
    required this.vehicleTypeId,
  });

  final String vehicleTypeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleTypeMasterViewModelProvider);

    return OpsShell(
      title: 'Vehicle Type Detail',
      currentRoute: RoutePaths.vehicleTypes,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          var item = data.items.isEmpty ? null : data.items.first;
          for (final entry in data.items) {
            if (entry.vehicleTypeId == vehicleTypeId) {
              item = entry;
              break;
            }
          }
          if (item?.vehicleTypeId != vehicleTypeId) {
            item = null;
          }
          if (item == null) {
            return const Center(child: Text('Vehicle Type not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: item.vehicleTypeName,
                subtitle: item.vehicleTypeId,
                icon: Icons.directions_car_filled_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Basic Info'),
                    _detailGrid([
                      _detail('Vehicle Type ID', item.vehicleTypeId),
                      _detail('Vehicle Type Name', item.vehicleTypeName),
                      _detail('Category', item.vehicleCategory.label),
                      _detail('Description', item.description.isEmpty ? '-' : item.description),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Capacity & Suitability'),
                    _detailGrid([
                      _detail('Seating Capacity', item.seatingCapacity == 0 ? '-' : '${item.seatingCapacity}'),
                      _detail('Load Capacity', item.loadCapacity == 0 ? '-' : '${item.loadCapacity} ton'),
                      _detail('Axle Type', item.axleType.label),
                      _detail('Body Type', item.bodyType.label),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Configuration'),
                    _detailGrid([
                      _detail('Fuel Type', item.fuelType.label),
                      _detail('Transmission', item.transmissionType.label),
                      _detail('AC Type', item.acType.label),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Business Rules'),
                    _detailGrid([
                      _detail('Base Fare / Km', item.baseFarePerKm.toStringAsFixed(2)),
                      _detail('Base Fare / Hour', item.baseFarePerHour.toStringAsFixed(2)),
                      _detail('Mileage', item.mileage.toStringAsFixed(2)),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Operational Rules'),
                    _detailGrid([
                      _detail('Max Trip Distance', item.maxTripDistance?.toString() ?? '-'),
                      _detail(
                        'Max Driving Hours / Day',
                        item.maxDrivingHoursPerDay?.toString() ?? '-',
                      ),
                      _detail('Status', item.status.label),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Documents'),
                    if (item.documents.isEmpty)
                      const Text('No template documents attached.')
                    else
                      _detailGrid([
                        for (final doc in item.documents)
                          _detail(
                            doc.documentType.label,
                            '${doc.documentName} | ${doc.filePath}',
                          ),
                      ]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _detailGrid(List<_DetailItem> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final item in items)
          Container(
            width: 250,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFDCE6F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _DetailItem _detail(String label, String value) =>
      _DetailItem(label: label, value: value);
}

class _DetailItem {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;
}
