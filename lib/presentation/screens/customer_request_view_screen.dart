import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/logistics_flow.dart';
import '../../routes/route_paths.dart';
import '../viewmodels/logistics_viewmodel.dart';
import '../widgets/ops_shell.dart';
import '../widgets/ops_ui.dart';

class CustomerRequestViewScreen extends ConsumerWidget {
  const CustomerRequestViewScreen({
    super.key,
    required this.enquiryNumber,
  });

  final String enquiryNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logisticsViewModelProvider);

    return OpsShell(
      title: 'View Enquiry',
      currentRoute: RoutePaths.customerRequest,
      actions: [
        TextButton(
          onPressed: () => context.go(RoutePaths.customerRequest),
          child: const Text('Back to Register'),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (data) {
          CustomerRequestData? enquiry;
          for (final item in data.customerRequests) {
            if (item.enquiryNumber == enquiryNumber) {
              enquiry = item;
              break;
            }
          }
          if (enquiry == null) {
            return const Center(child: Text('Enquiry not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OpsSectionCard(
                title: 'Enquiry ${enquiry.enquiryNumber}',
                subtitle: 'Detailed enquiry view with all captured values.',
                icon: Icons.visibility_outlined,
                accent: const Color(0xFF0EA5E9),
                trailing: OutlinedButton(
                  onPressed: () => context.go(
                    '${RoutePaths.customerRequestForm}?enquiryNumber=${enquiry!.enquiryNumber}',
                  ),
                  child: const Text('Edit'),
                ),
                child: Column(
                  children: [
                    _pair('Status', enquiry.status, 'Request Date',
                        enquiry.requestDate),
                    _pair('Request Source', enquiry.requestSource,
                        'Request Type', enquiry.requestType),
                    _pair('Customer', enquiry.customerName, 'Email/Reference',
                        enquiry.emailOrReference),
                    _pair('Contact', enquiry.contact, 'Cargo Type',
                        enquiry.cargoType),
                    _pair(
                        'Hazardous',
                        enquiry.hazardous ? 'Hazardous' : 'Non-Hazardous',
                        'PDO/Non-PDO',
                        enquiry.pdoSpec),
                    _pair('Pickup', enquiry.pickup, 'Destination',
                        enquiry.delivery),
                    _pair(
                        'Route',
                        enquiry.route.isEmpty ? '-' : enquiry.route,
                        'Quantity',
                        enquiry.quantity.isEmpty ? '-' : enquiry.quantity),
                    _pair(
                        'Dimensions',
                        enquiry.dimensions.isEmpty ? '-' : enquiry.dimensions,
                        'Weight/Volume',
                        enquiry.weightVolume.isEmpty
                            ? '-'
                            : enquiry.weightVolume),
                    _pair(
                      'Required Vehicle Type',
                      enquiry.requiredVehicleType.isEmpty
                          ? '-'
                          : enquiry.requiredVehicleType,
                      'Tentative Dispatch Date',
                      enquiry.tentativeDispatchDate.isEmpty
                          ? '-'
                          : enquiry.tentativeDispatchDate,
                    ),
                    _pair(
                        'Route Risk Flag',
                        enquiry.routeRiskFlag ? 'Yes' : 'No',
                        'Hazard Compliance',
                        enquiry.hazardousComplianceRequired
                            ? 'Required'
                            : 'Not Required'),
                    _single(
                        'Customer Requirement',
                        enquiry.customerSpecificRequirement.isEmpty
                            ? '-'
                            : enquiry.customerSpecificRequirement),
                    _single(
                        'Notes', enquiry.notes.isEmpty ? '-' : enquiry.notes),
                    _single(
                      'Cancellation Reason',
                      enquiry.cancellationReason.isEmpty
                          ? '-'
                          : enquiry.cancellationReason,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pair(String l1, String v1, String l2, String v2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: _kv(l1, v1)),
          const SizedBox(width: 12),
          Expanded(child: _kv(l2, v2)),
        ],
      ),
    );
  }

  Widget _single(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _kv(label, value),
    );
  }

  Widget _kv(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
