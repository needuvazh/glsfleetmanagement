import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routes/route_paths.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class VendorViewScreen extends ConsumerWidget {
  const VendorViewScreen({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorViewModelProvider);

    return OpsShell(
      title: 'Vendor Details',
      currentRoute: RoutePaths.vendorMaster,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.vendorMaster),
          child: const Text('Back to List'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          var vendor = data.vendors.isEmpty ? null : data.vendors.first;
          var found = false;
          for (final entry in data.vendors) {
            if (entry.vendorId == vendorId) {
              vendor = entry;
              found = true;
              break;
            }
          }

          if (!found || vendor == null) {
            return const Center(child: Text('Vendor not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: vendor.vendorName,
                subtitle: 'Read-only Vendor Master details',
                icon: Icons.visibility_outlined,
                accent: const Color(0xFF0EA5E9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Vendor ID', vendor.vendorId),
                    _row('Vendor Name', vendor.vendorName),
                    _row('Company Name', vendor.companyName),
                    _row('Contact Number', vendor.contactNumber),
                    _row('Email', vendor.email),
                    _row('Address', vendor.address),
                    _row('Vendor Type', vendor.vendorType.label),
                    _row('Service Type', vendor.serviceType.label),
                    _row('Status', vendor.status.label),
                    _row('Created At', vendor.createdAt.toIso8601String()),
                    _row('Updated At', vendor.updatedAt.toIso8601String()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
