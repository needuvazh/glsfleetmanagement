import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/fleet_master_model.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/fleet_master_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class FleetDetailScreen extends ConsumerWidget {
  const FleetDetailScreen({
    super.key,
    required this.fleetId,
    this.initialTab,
  });

  final String fleetId;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fleetMasterViewModelProvider);

    return OpsShell(
      title: 'Fleet Detail',
      currentRoute: RoutePaths.fleetManagement,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          FleetMasterModel? fleet;
          for (final item in data.fleets) {
            if (item.fleetId == fleetId) {
              fleet = item;
              break;
            }
          }
          if (fleet == null) {
            return const Center(child: Text('Fleet not found.'));
          }

          final vehicleType = data.vehicleTypeFor(fleet.vehicleTypeId);
          final vendor = data.vendorFor(fleet.vendorId);
          final compliance = fleet.complianceBadges(DateTime.now());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: fleet.fleetNumber,
                subtitle: vehicleType?.vehicleTypeName ?? fleet.vehicleTypeId,
                icon: Icons.local_shipping_outlined,
                accent: const Color(0xFF2563EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context, 'Basic Info'),
                    _detailGrid([
                      _detail('Fleet ID', fleet.fleetId),
                      _detail('Fleet Number', fleet.fleetNumber),
                      _detail('Vehicle Type', vehicleType?.vehicleTypeName ?? '-'),
                      _detail('Ownership', fleet.ownershipType.label),
                      _detail('Status', fleet.status.label),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Registration'),
                    _detailGrid([
                      _detail('Registration Number', fleet.registrationNumber),
                      _detail(
                        'Registration Expiry',
                        _formatDate(fleet.registrationExpiryDate),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Compliance'),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final item in compliance)
                          _ComplianceTile(
                            label: item.label,
                            value: _formatDate(item.expiryDate),
                            state: item.state,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Technical'),
                    _detailGrid([
                      _detail(
                        'Capacity',
                        fleet.capacityOverride?.toString() ??
                            (vehicleType?.capacityLabel ?? '-'),
                      ),
                      _detail('Axle Type', fleet.axleType.label),
                      _detail('Fuel Type', fleet.fuelType.label),
                      _detail('Body Type', fleet.bodyType.label),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Operational'),
                    _detailGrid([
                      _detail('Availability', fleet.availabilityStatus.label),
                      _detail('Maintenance', fleet.maintenanceStatus.label),
                      _detail(
                        'Current Trip Ref',
                        fleet.currentTripId.isEmpty ? '-' : fleet.currentTripId,
                      ),
                      _detail(
                        'Assignable',
                        fleet.isAssignable(DateTime.now()) ? 'Yes' : 'No',
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Vendor & Audit'),
                    _detailGrid([
                      _detail(
                        'Vendor',
                        vendor?.vendorName ?? (fleet.vendorId.isEmpty ? '-' : fleet.vendorId),
                      ),
                      _detail('Created By', fleet.createdBy),
                      _detail('Created At', _formatDateTime(fleet.createdAt)),
                      _detail('Updated By', fleet.updatedBy),
                      _detail('Updated At', _formatDateTime(fleet.updatedAt)),
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

class _ComplianceTile extends StatelessWidget {
  const _ComplianceTile({
    required this.label,
    required this.value,
    required this.state,
  });

  final String label;
  final String value;
  final ComplianceIndicatorType state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      ComplianceIndicatorType.valid => const Color(0xFF15803D),
      ComplianceIndicatorType.expiringSoon => const Color(0xFFF59E0B),
      ComplianceIndicatorType.expired => const Color(0xFFB91C1C),
    };

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value),
          const SizedBox(height: 8),
          Text(
            state.label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _formatDateTime(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}
